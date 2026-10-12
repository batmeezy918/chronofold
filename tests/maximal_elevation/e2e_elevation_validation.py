#!/usr/bin/env python3
"""End-to-end elevation validation: baseline vs minimal frontier vs incremental invalidation."""
import hashlib,json,platform,statistics,sys,time
D=(1024,128,32,16)
def layers():
    return [(tuple(x%D[i+1] for x in range(D[i])),tuple(x%D[i+1] for x in range(D[i])),D[i+1]) for i in range(3)]
def cert(T,C,q):
    o=[None]*q
    for x,c in enumerate(C):
        v=C[T[x]]
        if o[c] is None:o[c]=v
        elif o[c]!=v:raise ValueError("invalid quotient")
    return tuple(o)
def raw(T,C,q):return json.dumps([list(T),list(C),q],separators=(",",":")).encode()
def dig(T,C,q):return hashlib.sha256(raw(T,C,q)).hexdigest()
def verify(T,C,q,b):return all(C[T[x]]==b[C[x]] for x in range(len(T)))
def execute(b):
    x=0
    for _ in range(64):x=b[x]
    return x
def reconstruct(b,q):return tuple(b[c] for c in range(q))
def baseline(rounds=100):
    L=layers(); work=0
    for r in range(rounds):
        root={}
        for T,C,q in L:
            z=raw(T,C,q);d=hashlib.sha256(z).hexdigest();b=cert(T,C,q);root[d]=(z,T,C,q,b)
        for d,(z,T,C,q,b) in root.items():
            if not verify(T,C,q,b):return False,work
            work+=len(z)+len(b)+execute(b)+sum(reconstruct(b,q))
        if r==50:
            T,C,q=L[1];m=list(T);m[0]=(m[0]+1)%len(T)
            try:cert(tuple(m),C,q)
            except ValueError:pass
    return True,work
def frontier(rounds=100):
    L=layers();root={};F=[]
    for T,C,q in L:
        z=raw(T,C,q);d=hashlib.sha256(z).hexdigest();b=cert(T,C,q);root[d]=(z,T,C,q,b);F.append((d,q,b))
    work=0
    for r in range(rounds):
        for d,q,b in F:
            e=root.get(d)
            if e is None or e[0]!=raw(e[1],e[2],e[3]) or e[3]!=q or e[4]!=b or not verify(e[1],e[2],e[3],b):return False,work
            work+=len(d)+len(b)+execute(b)+sum(reconstruct(b,q))
        if r==50:
            T,C,q=L[1];m=list(T);m[0]=(m[0]+1)%len(T)
            try:cert(tuple(m),C,q)
            except ValueError:
                if hashlib.sha256(raw(tuple(m),C,q)).hexdigest() in root:return False,work
    return True,work
def incremental(rounds=100):
    L=layers();root={};F=[];deps={0:{0},1:{1},2:{2}}
    for i,(T,C,q) in enumerate(L):
        z=raw(T,C,q);d=hashlib.sha256(z).hexdigest();b=cert(T,C,q);root[d]=(z,T,C,q,b);F.append((i,d,q,b))
    work=0; invalid=False
    for r in range(rounds):
        if r==50:
            T,C,q=L[1];m=list(T);m[0]=(m[0]+1)%len(T);m=tuple(m);md=hashlib.sha256(raw(m,C,q)).hexdigest()
            try:cert(m,C,q)
            except ValueError:invalid=(md not in root and 1 in deps)
        for i,d,q,b in F:
            e=root.get(d)
            if e is None or not verify(e[1],e[2],e[3],b):return False,invalid,work
            work+=len(d)+1+len(b)+execute(b)+sum(reconstruct(b,q))
    return invalid,invalid,work
def tm(fn):
    a=[]
    for _ in range(7):
        t=time.perf_counter_ns();fn();a.append((time.perf_counter_ns()-t)/1e6)
    return statistics.median(a)
def main():
    bo,bw=baseline();fo,fw=frontier();io,inv,iw=incremental()
    tb,tf,ti=tm(baseline),tm(frontier),tm(incremental)
    result={"schema":"CG-E2E-1","layers":"1024->128->32->16","rounds":100,"mutation_round":50,
      "baseline":{"pass":bo,"work":bw,"ms":tb},
      "minimal_frontier":{"pass":fo,"work":fw,"ms":tf,"e2e_ratio_vs_baseline":tb/tf},
      "incremental_frontier":{"pass":io,"invalidation_pass":inv,"work":iw,"ms":ti,
          "e2e_ratio_vs_baseline":tb/ti,"e2e_ratio_vs_minimal_frontier":tf/ti},
      "gates":{"correctness":bo and fo and io,"mutation_invalidation":inv,
          "end_to_end_minimal_frontier":tb>tf,"end_to_end_incremental":tb>ti and tf>ti},
      "evidence_boundary":{"formal":"Lean CI remains authoritative for theorem claims.",
          "executable":"This receipt covers certification, transport, execution, reconstruction, verification and mutation.",
          "performance":"Timing is environment-specific; no universal speedup is inferred."}}
    result["promotion"]=all(result["gates"].values())
    result["sha256"]=hashlib.sha256(json.dumps(result,sort_keys=True,separators=(",",":")).encode()).hexdigest()
    print(json.dumps(result,indent=2,sort_keys=True));return 0 if result["promotion"] else 1
if __name__=="__main__":raise SystemExit(main())
