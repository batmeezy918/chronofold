"""
Constitution Data Structures & Schema Representation
=====================================================
Defines machine-readable constitution structures, rules, and compiled
rule metadata.
"""

from dataclasses import dataclass, field, asdict
from typing import Dict, List, Any, Callable
from agd.canonical import sha256_hash

@dataclass
class CompiledRuleValidator:
    rule_id: str
    authority_id: str
    source_hash: str
    constitution_version: str
    generated_code_hash: str
    validator_fn: Callable[[Dict[str, Any]], bool]
    description: str = ""

    def validate(self, target_data: Dict[str, Any]) -> Dict[str, Any]:
        passed = self.validator_fn(target_data)
        return {
            "rule_id": self.rule_id,
            "authority_id": self.authority_id,
            "constitution_version": self.constitution_version,
            "source_hash": self.source_hash,
            "generated_code_hash": self.generated_code_hash,
            "passed": passed
        }

@dataclass
class Constitution:
    constitution_id: str
    constitution_version: str
    authority_set: List[str]
    schema_version: str
    state_schema: Dict[str, Any]
    equivalence_relation: Dict[str, Any]
    invariants: List[Dict[str, Any]]
    lawful_operators: List[str]
    forbidden_operators: List[str]
    admission_rules: List[Dict[str, Any]]
    projection_rules: Dict[str, Any] = field(default_factory=dict)
    reconstruction_rules: Dict[str, Any] = field(default_factory=dict)
    error_rules: Dict[str, Any] = field(default_factory=dict)
    evidence_rules: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

    def compute_hash(self) -> str:
        return sha256_hash(self.to_dict())
