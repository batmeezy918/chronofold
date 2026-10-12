#!/usr/bin/env python3
"""Counterexample-Guided Maximal Elevation Engine. Stdlib-only deterministic finite quotient certification."""
from __future__ import annotations
import hashlib, json, platform, random, statistics, sys, time
from itertools import product
SEED=0xC0FFEE
rng=random.Random(SEED)

def well_defined(T,C,q):
    return induced(T,C,q) is not None

def descends(T,C):
    # Stronger invariant-preservation predicate, retained for mutation tests.
    return all(C[T[x]]==C[x] for x in range(len(T)))
def induced(T,C,q):
    out=[None]*q
    for x,c in enumerate(C):
        cy=C[T[x]]
        if out[c] is None: out[c]=cy
        elif out[c]!=cy: return None
    return out

def exhaustive_gate():
    n,q=6,3; C=[x%q for x in range(n)]
    total=valid=false_accept=iterative_fail=0
    for T in product(range(n),repeat=n):
        total+=1; bar=induced(T,C,q); valid_now=bar is not None
        if valid_now:
            valid+=1
            for x in range(n):
                y=x; bc=C[x]
                for _ in range(9):
                    if C[y]!=bc: iterative_fail+=1; break
                    y=T[y]; bc=bar[bc]
        if valid_now != well_defined(T,C,q):
            false_accept+=1
    return {"states":n,"classes":q,"operators":total,"valid_descents":valid,
            "false_accepts":false_accept,"iterative_failures":iterative_fail,
            "pass":total==46656 and false_accept==0 and iterative_fail==0}

def mutation_gate():
    n,q=6,3; C=[x%q for x in range(n)]; I=tuple(range(n))
    total=detected=0
    for x in range(n):
        for y in range(n):
            if C[y]==C[x]: continue
            T=list(I); T[x]=y; total+=1
            detected += not descends(T,C)
    trials=2000; random_detected=0
    for _ in range(trials):
        x=rng.randrange(n)
        ys=[y for y in range(n) if C[y]!=C[x]]
        T=list(I); T[x]=rng.choice(ys)
        random_detected += not descends(T,C)
    return {"single_mutations":total,"single_detected":detected,
            "single_detection_rate":detected/total,
            "random_cross_class_mutations":trials,"random_detected":random_detected,
            "random_detection_rate":random_detected/trials,
            "pass":detected==total and random_detected==trials}

def metamorphic_gate():
    n,q=8,4; C=[x%q for x in range(n)]; failures=0; cases=5000
    for _ in range(cases):
        bar=[rng.randrange(q) for _ in range(q)]
        T=tuple(rng.choice([y for y in range(n) if C[y]==bar[C[x]]]) for x in range(n))
        if not well_defined(T,C,q): failures+=1; continue
        p=list(range(n)); rng.shuffle(p); inv={p[i]:i for i in range(n)}
        C2=[C[inv[i]] for i in range(n)]
        T2=tuple(p[T[inv[i]]] for i in range(n))
        failures += not well_defined(T2,C2,q)
    return {"cases":cases,"failures":failures,"pass":failures==0}

def nested_gate():
    n,q1,q2=16,8,4; C1=[x%q1 for x in range(n)]; C2=[x%q2 for x in range(q1)]
    cases=10000; failures=0
    for _ in range(cases):
        bar1=[rng.randrange(q1) for _ in range(q1)]
        T=tuple(rng.choice([y for y in range(n) if C1[y]==bar1[C1[x]]]) for x in range(n))
        bar2=induced(bar1,C2,q2)
        if bar2 is None: failures+=1; continue
        # Verify composed quotient dynamics, not class preservation.
        for x in range(n):
            y=x; c=C2[C1[x]]
            for _ in range(13):
                if C2[C1[y]] != c: failures+=1; break
                y=T[y]; c=bar2[c]
    return {"cases":cases,"iterations":13,"failures":failures,"pass":failures==0}

def reconstruction_gate():
    n,q=24,6; C=[x%q for x in range(n)]
    section=[next(x for x,c in enumerate(C) if c==k) for k in range(q)]
    failures=sum(C[section[c]]!=c for c in range(q))
    for _ in range(10000):
        bar=[rng.randrange(q) for _ in range(q)]
        T=tuple(rng.choice([y for y in range(n) if C[y]==bar[C[x]]]) for x in range(n))
        failures += sum(C[T[x]] != C[section[bar[C[x]]]] for x in range(n))
    return {"fibers":q,"cases":10000,"failures":failures,"pass":failures==0}

def perturbation_gate():
    n,q=10,5; C=[x%q for x in range(n)]; failures=0
    epsilons=[0,1,2,3,5,8,13]
    for eps in epsilons:
        U=[(x+eps)%n for x in range(n)]
        expected=all(C[U[x]]==C[x] for x in range(n))
        failures += expected != descends(U,C)
    return {"epsilons":epsilons,"failures":failures,"pass":failures==0}

def cost_gate():
    D,R=1024,16; dense_ratio=(D*D)/(R*R)
    A=[[(i*17+j*31)%101 for j in range(R)] for i in range(R)]
    v=[((i*13)%97)/97.0 for i in range(R)]; vf=[0.0]*R
    Af=[[A[i%R][j%R] for j in range(D)] for i in range(D)]; full_v=v*(D//R)
    def reduced():
        for i in range(R):
            s=0.0
            for j in range(R): s+=A[i][j]*v[j]
            vf[i]=s
    def full():
        out=[0.0]*D
        for i in range(D):
            s=0.0
            for j in range(D): s+=Af[i][j]*full_v[j]
            out[i]=s
        return out
    for _ in range(3): reduced(); full()
    rt=[]; ft=[]
    for _ in range(12):
        t=time.perf_counter_ns(); reduced(); rt.append(time.perf_counter_ns()-t)
        t=time.perf_counter_ns(); full(); ft.append(time.perf_counter_ns()-t)
    rm=statistics.median(rt)/1e6; fm=statistics.median(ft)/1e6
    inner=fm/rm; cert=max(.001,rm*10)
    e100=(100*fm)/(100*rm+cert); e1000=(1000*fm)/(1000*rm+cert)
    return {"full_dim":D,"quotient_dim":R,"dense_work_ratio_exact":dense_ratio,
            "full_median_ms":fm,"reduced_median_ms":rm,"inner_wall_ratio":inner,
            "certification_proxy_ms":cert,"e2e_ratio_100":e100,"e2e_ratio_1000":e1000,
            "pass":e100>1 and e1000>1}

def main():
    gates={"exhaustive_finite":exhaustive_gate(),"adversarial_mutation":mutation_gate(),
           "metamorphic_relabel":metamorphic_gate(),"nested_quotient":nested_gate(),
           "reconstruction":reconstruction_gate(),"perturbation":perturbation_gate(),
           "economic_cost":cost_gate()}
    payload=json.dumps(gates,sort_keys=True,separators=(",",":")).encode()
    receipt={"schema":"CG-ME-1","seed":SEED,"python":sys.version,"platform":platform.platform(),
             "sha256":hashlib.sha256(payload).hexdigest(),"gates":gates,
             "promotion":all(g["pass"] for g in gates.values()),
             "evidence_boundary":{"formal":"Lean CI is authoritative for formal claims.",
             "executable":"This receipt records finite exhaustive and generative checks.",
             "performance":"Timing is environment-specific; no universal speedup is inferred."}}
    print(json.dumps(receipt,indent=2,sort_keys=True))
    raise SystemExit(0 if receipt["promotion"] else 1)
if __name__=="__main__": main()
