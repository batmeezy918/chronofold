"""
Constitution Compiler
======================
Compiles machine-readable constitution JSON structures into executable
state, transition, and invariant validators. Retains cryptographic provenance
for every rule.
"""

from typing import Dict, List, Any
from agd.canonical import sha256_hash, canonical_json_dumps
from constitution.model import Constitution, CompiledRuleValidator

class ConstitutionCompiler:
    def __init__(self, constitution: Constitution):
        self.constitution = constitution
        self.constitution_hash = constitution.compute_hash()
        self.compiled_validators: Dict[str, CompiledRuleValidator] = {}

    def compile(self) -> Dict[str, CompiledRuleValidator]:
        """
        Compiles all invariants and admission rules into executable CompiledRuleValidator objects.
        """
        # 1. Compile Invariants
        for inv in self.constitution.invariants:
            rule_id = inv["rule_id"]
            auth_id = inv["authority_id"]
            field_name = inv.get("field")
            expected_type = inv.get("type")
            min_val = inv.get("min")

            # Create deterministic validator function
            def _make_inv_validator(fn_field=field_name, fn_type=expected_type, fn_min=min_val):
                def validator(state: Dict[str, Any]) -> bool:
                    val = state.get(fn_field)
                    if val is None:
                        # Check inside nested dicts if needed
                        parts = fn_field.split('.')
                        curr = state
                        for p in parts:
                            if isinstance(curr, dict) and p in curr:
                                curr = curr[p]
                            else:
                                return False
                        val = curr

                    if fn_type == "int" and not isinstance(val, int):
                        return False
                    if fn_type == "str" and not isinstance(val, str):
                        return False
                    if fn_min is not None and isinstance(val, (int, float)) and val < fn_min:
                        return False
                    return True
                return validator

            fn = _make_inv_validator()
            source_h = sha256_hash(inv)
            code_h = sha256_hash(f"INV_{rule_id}_{field_name}_{expected_type}")

            validator_obj = CompiledRuleValidator(
                rule_id=rule_id,
                authority_id=auth_id,
                source_hash=source_h,
                constitution_version=self.constitution.constitution_version,
                generated_code_hash=code_h,
                validator_fn=fn,
                description=inv.get("description", "")
            )
            self.compiled_validators[rule_id] = validator_obj

        # 2. Compile Operator Lawfulness Check
        def lawful_operator_validator(transition: Dict[str, Any]) -> bool:
            op = transition.get("operator")
            if not op:
                return False
            if op in self.constitution.forbidden_operators:
                return False
            return op in self.constitution.lawful_operators

        source_h = sha256_hash({
            "lawful": self.constitution.lawful_operators,
            "forbidden": self.constitution.forbidden_operators
        })
        code_h = sha256_hash("LAWFUL_OPERATOR_VALIDATOR_V1")

        self.compiled_validators["RULE_LAWFUL_OPERATORS"] = CompiledRuleValidator(
            rule_id="RULE_LAWFUL_OPERATORS",
            authority_id=self.constitution.authority_set[0] if self.constitution.authority_set else "EMVCO",
            source_hash=source_h,
            constitution_version=self.constitution.constitution_version,
            generated_code_hash=code_h,
            validator_fn=lawful_operator_validator,
            description="Verifies operator is in lawful list and not in forbidden list."
        )

        # 3. Compile Admission Rules
        for adm in self.constitution.admission_rules:
            rule_id = adm["rule_id"]
            auth_id = adm["authority_id"]
            req_prev_states = adm.get("required_prev_states") or adm.get("required_prev_state")
            if isinstance(req_prev_states, str):
                req_prev_states = [req_prev_states]
            target_op = adm.get("operator")

            def _make_adm_validator(r_prev=req_prev_states, t_op=target_op):
                def validator(transition: Dict[str, Any]) -> bool:
                    op = transition.get("operator")
                    prev_state = transition.get("state_before", {}).get("stage")
                    if t_op and op == t_op:
                        if r_prev and prev_state not in r_prev:
                            return False
                    return True
                return validator

            fn = _make_adm_validator()
            source_h = sha256_hash(adm)
            code_h = sha256_hash(f"ADM_{rule_id}_{target_op}_{req_prev_states}")

            self.compiled_validators[rule_id] = CompiledRuleValidator(
                rule_id=rule_id,
                authority_id=auth_id,
                source_hash=source_h,
                constitution_version=self.constitution.constitution_version,
                generated_code_hash=code_h,
                validator_fn=fn,
                description=adm.get("description", "")
            )

        return self.compiled_validators

    def validate_state(self, state: Dict[str, Any]) -> Dict[str, Any]:
        results = {}
        all_passed = True
        for rule_id, validator in self.compiled_validators.items():
            if rule_id.startswith("INV_"):
                res = validator.validate(state)
                results[rule_id] = res
                if not res["passed"]:
                    all_passed = False
        return {
            "valid": all_passed,
            "constitution_hash": self.constitution_hash,
            "rule_results": results
        }

    def validate_transition(self, transition: Dict[str, Any]) -> Dict[str, Any]:
        results = {}
        all_passed = True
        for rule_id, validator in self.compiled_validators.items():
            if rule_id.startswith("ADM_") or rule_id == "RULE_LAWFUL_OPERATORS":
                res = validator.validate(transition)
                results[rule_id] = res
                if not res["passed"]:
                    all_passed = False
        return {
            "admitted": all_passed,
            "constitution_hash": self.constitution_hash,
            "rule_results": results
        }
