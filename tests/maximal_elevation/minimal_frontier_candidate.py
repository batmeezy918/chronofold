#!/usr/bin/env python3
"""Minimal certified descent frontier; executable benchmark, not a Lean theorem."""
import hashlib,json,platform,statistics,sys,time

def canonical(T,C,q):
    return json.dumps([list(T),list(C),q],separators=(",",":")).encode()

def certify(T,C,q):
    out=[None]*q
    for x,c in enumerate(C):
        value=C[T[x]]
        if out[c] is None: out[c]=value
        elif out[c]!=value: raise ValueError("invalid quotient")
    return tuple(out)

def run():
    dims=[1024,128,32,16]
    layers=[]
    for i in range(3):
        T=tuple(x%dims[i+1] for x in range(dims[i]))
        C=tuple(x%dims[i+1] for x in range(dims[i]))
        layers.append((T,C,dims[i+1]))
    root={}; frontier=[]; failures=0
    # Root setup: exact structural key and certificate are validated once.
    for T,C,q in layers:
        raw=canonical(T,C,q); digest=hashlib.sha256(raw).hexdigest()
        bar=certify(T,C,q)
        root[digest]=(raw,(T,C,q),bar)
        frontier.append((digest,q,bar))
    # Exact structural validation occurs at frontier handoff, not every visit.
    for (T,C,q),(digest,fq,fbar) in zip(layers,frontier):
        entry=root.get(digest)
        if entry is None or entry[0]!=canonical(T,C,q) or fq!=q or fbar!=certify(T,C,q):
            failures+=1
    # Mutation must not match original certificate and must fail certification.
    T,C,q=layers[1]; mutated=list(T); mutated[0]=(mutated[0]+1)%len(T); mutated=tuple(mutated)
    mutated_digest=hashlib.sha256(canonical(mutated,C,q)).hexdigest()
    try:
        certify(mutated,C,q); mutation_rejected=False
    except ValueError:
        mutation_rejected=True
    invalidation=mutated_digest not in root and mutation_rejected
    full_payload=json.dumps([{"T":T,"C":C,"q":q,"bar":certify(T,C,q)} for T,C,q in layers],separators=(",",":")).encode()
    frontier_payload=json.dumps(frontier,separators=(",",":")).encode()
    repeats=1000
    def recertify():
        n=0
        for _ in range(repeats):
            for T,C,q in layers: n+=len(certify(T,C,q))
        return n
    def reuse_frontier():
        n=0
        for _ in range(repeats):
            for digest,q,bar in frontier:
                if digest not in root: raise ValueError("stale frontier")
                n+=len(bar)
        return n
    recertify(); reuse_frontier(); a=[]; b=[]
    for _ in range(7):
        t=time.perf_counter_ns(); recertify(); a.append(time.perf_counter_ns()-t)
        t=time.perf_counter_ns(); reuse_frontier(); b.append(time.perf_counter_ns()-t)
    recert_ms=statistics.median(a)/1e6; reuse_ms=statistics.median(b)/1e6
    ratio=recert_ms/reuse_ms if reuse_ms else float("inf")
    result={
        "candidate":"minimal-certified-descent-frontier-v1",
        "layers":"1024->128->32->16","transformations":len(layers),
        "repeated_visits":repeats,"correctness_failures":failures,
        "adversarial_invalidation_pass":bool(invalidation),
        "full_payload_bytes":len(full_payload),"frontier_payload_bytes":len(frontier_payload),
        "payload_reduction_ratio":len(full_payload)/len(frontier_payload),
        "recertification_ms":recert_ms,"frontier_reuse_ms":reuse_ms,
        "reuse_time_ratio":ratio,"python":sys.version,"platform":platform.platform(),
        "pass":failures==0 and invalidation and len(frontier_payload)<len(full_payload) and ratio>1
    }
    result["sha256"]=hashlib.sha256(json.dumps(result,sort_keys=True,separators=(",",":")).encode()).hexdigest()
    print(json.dumps(result,indent=2,sort_keys=True))
    return 0 if result["pass"] else 1

if __name__=="__main__":
    raise SystemExit(run())
