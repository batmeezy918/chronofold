import json

def snap_step(x):
    x[1] += 1
    x[2] = 2*x[1] - x[0] + (x[2] - 2*x[1] + x[0])
    return x

def f(x):
    return sum(v*v for v in x)

x = [1, 2, 3]

for i in range(100):
    x = snap_step(x)

result = {
    "final_state": x,
    "objective": f(x),
    "iterations": 100
}

with open("snap_result.json", "w") as f_out:
    json.dump(result, f_out)

print(result)

