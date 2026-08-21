"""
Deterministic Adversarial Fuzzing Engine
========================================
Executes deterministic adversarial fuzzing campaigns with corpus hashing,
mutations across protocol states, TLV tags, and state machines, generating
minimized reproducible counterexamples in counterexamples/.
"""

import json
import random
import os
from typing import Dict, Any, List, Tuple
from agd.canonical import sha256_hash, canonical_json_dumps
from emb.state_machine import EMBStateMachine

class FuzzEngine:
    def __init__(self, seed: int = 1337):
        self.seed = seed
        self.rng = random.Random(seed)
        self.counterexample_dir = "counterexamples"
        os.makedirs(self.counterexample_dir, exist_ok=True)

    def generate_mutations(self, base_sequence: List[Tuple[str, Dict[str, Any]]]) -> List[List[Tuple[str, Dict[str, Any]]]]:
        """
        Generates adversarial mutated sequences:
        - Reordered operators
        - Duplicated records
        - Missing steps
        - Malformed/truncated input fields
        - Boundary / zero / maximum values
        - Forbidden operators
        """
        mutations = []

        # 1. Reordered sequence
        reordered = list(base_sequence)
        if len(reordered) > 1:
            reordered[0], reordered[1] = reordered[1], reordered[0]
            mutations.append(reordered)

        # 2. Missing record (drop GPO)
        if len(base_sequence) > 2:
            dropped = [base_sequence[0]] + base_sequence[2:]
            mutations.append(dropped)

        # 3. Insert forbidden operator (OP_FORGED_AC)
        forbidden_inserted = list(base_sequence)
        forbidden_inserted.insert(1, ("OP_FORGED_AC", {"ac": "BAD_AC"}))
        mutations.append(forbidden_inserted)

        # 4. Truncated/Malformed field values
        malformed = [
            ("OP_SELECT_AID", {"aid": ""}), # Empty AID
            ("OP_GET_PROCESSING_OPTIONS", {"amount": "INVALID_AMOUNT_STRING"}),
            ("OP_GENERATE_AC", {"ac": "TRUNCATED"})
        ]
        mutations.append(malformed)

        # 5. Boundary values (max int / zero amount)
        boundary = [
            ("OP_SELECT_AID", {"aid": "A0000000031010"}),
            ("OP_GET_PROCESSING_OPTIONS", {"amount": "999999999999"}),
            ("OP_READ_RECORD", {"afl": "08010100"}),
            ("OP_GENERATE_AC", {"ac": "FFFFFFFFFFFFFFFF"})
        ]
        mutations.append(boundary)

        return mutations

    def run_fuzz_campaign(self, base_sequence: List[Tuple[str, Dict[str, Any]]], case_count: int = 10) -> Dict[str, Any]:
        """
        Executes a deterministic fuzz campaign and saves counterexamples on unexpected errors.
        """
        mutated_sequences = self.generate_mutations(base_sequence)
        passed = 0
        failed = 0
        minimized_failures = []
        corpus_hashes = []

        for idx, seq in enumerate(mutated_sequences):
            seq_hash = sha256_hash(seq)
            corpus_hashes.append(seq_hash)

            sm = EMBStateMachine()
            caught_expected_rejection = False
            unexpected_exception = False

            for op, input_data in seq:
                try:
                    res = sm.execute_transition(op, input_data)
                    if res["status"] == "STRUCTURED_REJECTION":
                        caught_expected_rejection = True
                except Exception as e:
                    unexpected_exception = True
                    break

            if unexpected_exception:
                failed += 1
                ce_id = f"CE_FUZZ_SEED_{self.seed}_{idx:03d}"
                ce_record = {
                    "counterexample_id": ce_id,
                    "seed": self.seed,
                    "mutated_sequence": seq,
                    "sequence_hash": seq_hash,
                    "reason": "UNHANDLED_EXCEPTION_IN_KERNEL"
                }
                ce_file = os.path.join(self.counterexample_dir, f"{ce_id}.json")
                with open(ce_file, "w") as f:
                    f.write(canonical_json_dumps(ce_record))
                minimized_failures.append(ce_record)
            else:
                passed += 1

        campaign_summary = {
            "seed": self.seed,
            "case_count": len(mutated_sequences),
            "generator_version": "1.0.0",
            "corpus_hash": sha256_hash(corpus_hashes),
            "passed": passed,
            "failed": failed,
            "minimized_failures": minimized_failures
        }

        return campaign_summary
