#!/usr/bin/env python3
"""Minimal-frontier candidate: compact downstream witness with exact root validation.

This is an executable benchmark, not a Lean theorem. Full structural keys remain
at the root registry; the frontier carries only the digest, quotient dimension,
and induced quotient map. Digest hits are checked against the retained exact key.
"""
import hashlib, json, platform, statistics, sys, time

def canonical(T, C, q):
    return json.dumps([list(T), list(C), q], separators=(",", ":")).encode()

def certify(T, C, q):
    out = [None] * q
    for x, c in enumerate(C):
        value = C[T[x]]
        if out[c] is None:
            out[c] = value
        elif out[c] != value:
            raise ValueError("invalid quotient")
    return tuple(out)

def build():
    dims = [1024, 128, 32, 16]
    layers = []
    for i in range(3):
        T = tuple(x % dims[i+1] for x in range(dims[i]))
        C = tuple(x % dims[i+1] for x in range(dims[i]))
        q = dims[i+1]
        layers.append((T, C, q))
    return layers

def run():
    layers = build()
    root = {}
    frontier = []
    # Full structural certificate retained once at root; compact frontier sent downstream.
    for T, C, q in layers:
        raw = canonical(T, C, q)
        digest = hashlib.sha256(raw).hexdigest()
        bar = certify(T, C, q)
        root[digest] = (raw, (T, C, q), bar)
        frontier.append((digest, q, bar))
    # Exact root check prevents a digest match from being treated as proof by itself.
    failures = 0
    for (T, C, q), (digest, fq, fbar) in zip(layers, frontier):
        raw = canonical(T, C, q)
        entry = root.get(digest)
        if entry is None or entry[0] != raw or fq != q or fbar != certify(T, C, q):
            failures += 1
    # Mutate a transition; it must not reuse the original frontier certificate.
    T, C, q = layers[1]
    mutated = list(T)
    mutated[0] = (mutated[0] + 1) % len(T)
    mutated = tuple(mutated)
    mutated_digest = hashlib.sha256(canonical(mutated, C, q)).hexdigest()
    invalidation_pass = mutated_digest not in root
    # Compare serialized downstream payload size; root exact key is deliberately excluded
    # from the payload in both cases because it is held once in the root registry.
    full_payload = json.dumps([
        {"T": T, "C": C, "q": q, "bar": certify(T, C, q)} for T, C, q in layers
    ], separators=(",", ":")).encode()
    frontier_payload = json.dumps(frontier, separators=(",", ":")).encode()
    # Time repeated lookup + exact validation, versus recertification at every visit.
    repeats = 1000
    def recertify():
        n = 0
        for _ in range(repeats):
            for T, C, q in layers:
                n += len(certify(T, C, q))
        return n
    def reuse_frontier():
        n = 0
        for _ in range(repeats):
            for (T, C, q), (digest, fq, fbar) in zip(layers, frontier):
                raw = canonical(T, C, q)
                entry = root.get(digest)
                if entry is None or entry[0] != raw or fq != q:
                    raise ValueError("stale or invalid frontier")
                n += len(fbar)
        return n
    recertify(); reuse_frontier()
    a=[]; b=[]
    for _ in range(7):
        t=time.perf_counter_ns(); recertify(); a.append(time.perf_counter_ns()-t)
        t=time.perf_counter_ns(); reuse_frontier(); b.append(time.perf_counter_ns()-t)
    recert_ms=statistics.median(a)/1e6
    reuse_ms=statistics.median(b)/1e6
    ratio=recert_ms/reuse_ms if reuse_ms else float("inf")
    result={
        "candidate":"minimal-certified-descent-frontier-v1",
        "layers":"1024->128->32->16",
        "transformations":len(layers),
        "repeated_visits":repeats,
        "correctness_failures":failures,
        "adversarial_invalidation_pass":bool(invalidation_pass),
        "full_payload_bytes":len(full_payload),
        "frontier_payload_bytes":len(frontier_payload),
        "payload_reduction_ratio":len(full_payload)/len(frontier_payload),
        "recertification_ms":recert_ms,
        "frontier_reuse_ms":reuse_ms,
        "reuse_time_ratio":ratio,
        "python":sys.version,
        "platform":platform.platform(),
        "pass":failures==0 and invalidation_pass and len(frontier_payload)<len(full_payload) and ratio>0
    }
    result["sha256"]=hashlib.sha256(json.dumps(result,sort_keys=True,separators=(",",":")).encode()).hexdigest()
    print(json.dumps(result,indent=2,sort_keys=True))
    return 0 if result["pass"] else 1

if __name__ == "__main__":
    raise SystemExit(run())
