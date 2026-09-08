import csv, numpy as np
for f in ("XSCHEM_v3/datos_nav3/fino_nav2.csv",
          "XSCHEM/TEST_TOTAL/datos_nav2/fino_nav2.csv"):
    try: r=list(csv.DictReader(open("/foss/designs/a_zonetic2026/"+f)))
    except Exception as e: print(f,"->",e); continue
    cols=[c for c in r[0] if c.startswith("P_")]
    print(f"\n{f}")
    for c in cols:
        v=np.array([abs(float(x[c])) for x in r])*1e3   # mW
        print(f"   {c:8s} media {v.mean():7.2f} mW  pico {v.max():7.2f} mW"
              f"   ->  {v.mean()/5:6.2f} / {v.max()/5:6.2f} mA a 5 V")
