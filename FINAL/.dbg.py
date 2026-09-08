import numpy as np
from pathlib import Path
d = np.loadtxt("/foss/designs/a_zonetic2026/XSCHEM/TEST/simulation/test_opam_g100_tran.sch/slew.txt")
t, vin, e = d[:,0], d[:,1], d[:,3]
print("ventana", t[0]*1e6, "a", t[-1]*1e6, "us,", len(t), "muestras")
print("entrada", vin.min(), "->", vin.max(), " salida", e.min(), "->", e.max())
i = np.argmax(vin > 1.9)
print(f"\nel escalon empieza en la muestra {i}, t={t[i]*1e9:.2f} ns")
for k in range(i-2, min(i+40, len(t)), 3):
    print(f"   t={t[k]*1e9:9.3f} ns  vin={vin[k]:6.3f}  out={e[k]:7.4f}")
