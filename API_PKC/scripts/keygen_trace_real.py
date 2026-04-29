#!/usr/bin/env python3
import hashlib,glob,os,csv
ROOT=os.path.dirname(os.path.dirname(__file__))
objs=['seedbuf_full','rho','rhoprime','A','s1','t','dpk','tbar','packed_pk','packed_sk']
rows=[]
for impl in ['ref','avx2']:
  rec={'implementation':impl,'profile':'128'}
  for o in objs:
    p=f'{ROOT}/build/keygen_{impl}_{o}.bin'
    b=open(p,'rb').read()
    rec[o+'_sha256']=hashlib.sha256(b).hexdigest()
    if o=='seedbuf_full':
      rec['keygen_randombytes_len']=len(b)
      if len(b)<=128: rec['seedbuf_full_hex']=b.hex().upper()
    if o=='packed_pk':
      rec['packed_pk_first32_hex']=b[:32].hex().upper()
      rec['packed_pk_rest_sha256']=hashlib.sha256(b[32:]).hexdigest()
  rows.append(rec)
outtxt=f'{ROOT}/build/mamba_sign_keygen_trace_real.txt'
outcsv=f'{ROOT}/build/mamba_sign_keygen_trace_real.csv'
with open(outtxt,'w') as f:
  for r in rows:
    f.write(f"implementation={r['implementation']} profile=128\n")
    for k,v in r.items():
      if k in ('implementation','profile'): continue
      f.write(f"{k}={v}\n")
    f.write('\n')
keys=['implementation','profile']+[k for k in rows[0].keys() if k not in ('implementation','profile')]
with open(outcsv,'w',newline='') as f:
  w=csv.DictWriter(f,fieldnames=keys);w.writeheader();w.writerows(rows)
print(open(outtxt).read())
