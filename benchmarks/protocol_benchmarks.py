"""
Protocol Laboratory Performance Benchmark Suite
=================================================
Measures execution latency, throughput, memory overhead, certificate issuing overhead,
and replay speed compared against standard baseline models.
"""

import time
import sys
import gc
from typing import Dict, Any
from emb.state_machine import EMBStateMachine
from replay.engine import ReplayEngine
from certificates.engine import CertificateEngine
from agd.canonical import sha256_hash, get_environment_manifest

class BenchmarkSuite:
    def __init__(self, sample_count: int = 100):
        self.sample_count = sample_count

    def run_benchmarks(self) -> Dict[str, Any]:
        """
        Executes performance metrics gathering across protocol operations.
        """
        gc.collect()

        # 1. Benchmark Transition Latency & Throughput
        sm = EMBStateMachine()
        seq = [
            ("OP_SELECT_AID", {"aid": "A0000000031010"}),
            ("OP_GET_PROCESSING_OPTIONS", {"amount": "000000001000"}),
            ("OP_READ_RECORD", {"afl": "08010100"}),
            ("OP_GENERATE_AC", {"ac": "1234567890ABCDEF"})
        ]

        t0 = time.perf_counter()
        total_transitions = 0
        for _ in range(self.sample_count):
            sm_bench = EMBStateMachine()
            for op, inp in seq:
                sm_bench.execute_transition(op, inp)
                total_transitions += 1
        t1 = time.perf_counter()

        elapsed_sec = t1 - t0
        latency_per_transition_ms = (elapsed_sec / total_transitions) * 1000.0
        throughput_ops_per_sec = total_transitions / elapsed_sec if elapsed_sec > 0 else 0

        # 2. Benchmark Replay Speed
        re = ReplayEngine()
        t0_rep = time.perf_counter()
        for _ in range(self.sample_count):
            re.execute_trace(1337, seq)
        t1_rep = time.perf_counter()

        replay_elapsed = t1_rep - t0_rep
        replay_throughput_traces_per_sec = self.sample_count / replay_elapsed if replay_elapsed > 0 else 0

        # 3. Benchmark Certificate Issuing Overhead
        cert_engine = CertificateEngine("const_hash", "auth_hash", "impl_hash")
        t0_cert = time.perf_counter()
        for _ in range(self.sample_count * 10):
            cert_engine.issue_certificate(
                operator="OP_SELECT_AID",
                input_data={"aid": "A0000000031010"},
                state_before={"stage": "INIT"},
                state_after={"stage": "SELECTED"},
                phi_before={"stage": "INIT"},
                phi_after={"stage": "SELECTED"},
                invariant_results={"valid": True}
            )
        t1_cert = time.perf_counter()
        cert_elapsed = t1_cert - t0_cert
        cert_issuing_latency_us = (cert_elapsed / (self.sample_count * 10)) * 1_000_000.0

        baseline_metrics = {
            "baseline_description": "Unoptimized Python 3.12 sequential interpreter",
            "sample_count": self.sample_count,
            "total_transitions_evaluated": total_transitions,
            "latency_per_transition_ms": round(latency_per_transition_ms, 4),
            "throughput_ops_per_sec": round(throughput_ops_per_sec, 2),
            "replay_throughput_traces_per_sec": round(replay_throughput_traces_per_sec, 2),
            "certificate_issuing_latency_us": round(cert_issuing_latency_us, 2),
            "environment_manifest": get_environment_manifest()
        }

        return baseline_metrics
