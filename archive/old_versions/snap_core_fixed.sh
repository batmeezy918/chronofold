#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "======================================="
echo "SNAP CORE (DESCENT-SAFE OPERATOR)"
echo "======================================="

cat > snap_core.py << 'EOF'
import random, math

def sphere(x): return sum(v*v for v in x)

def grad(f,x,eps=1e-6):
    g=[]
    for i in range(len(x)):
        x1=x[:]; x2=x[:]
        x1[i]+=eps; x2[i]-=eps
        g.append((f(x1)-f(x2))/(2*eps))
    return g

# tangent projection
def project(g):
    g0,g1,g2 = g[0],g[1],g[2]
    g0_new = 0
    g1_new = (g1 + g2/2)/2
    g2_new = 2*g1_new

    g_new = g[:]
    g_new[0]=g0_new
    g_new[1]=g1_new
    g_new[2]=g2_new
    return g_new

# descent-safe operator
def descent_direction(g):
    v = project(g)
    dot = sum(g[i]*v[i] for i in range(len(g)))

    if dot <= 0:
        return g   # fallback
    return v

def step(f,x):
    g = grad(f,x)
    v = descent_direction(g)

    alpha = 0.1
    best = x
    best_val = f(x)

    for _ in range(8):
        x_new = [x[i] - alpha*v[i] for i in range(len(x))]
        val = f(x_new)
        if val < best_val:
            best = x_new
            best_val = val
        alpha *= 0.5

    return best

# run
x = [random.uniform(-5,5) for _ in range(10)]
best = sphere(x)

for _ in range(200):
    x = step(sphere,x)
    val = sphere(x)
    if val < best:
        best = val

print("FINAL:", best)
EOF

python snap_core.py

echo "======================================="
echo "DONE"
echo "======================================="
