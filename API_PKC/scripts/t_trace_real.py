#!/usr/bin/env python3
import hashlib,csv,os
ROOT=os.path.dirname(os.path.dirname(__file__))
steps=['ttrace_s1_before_ntt','ttrace_s1_after_ntt','ttrace_A_canonical','ttrace_pointwise_product','ttrace_accumulated_t_ntt','ttrace_after_invntt_before_reduce','ttrace_after_reduce','ttrace_dpk','ttrace_tbar','ttrace_packed_pk_rest']
rows=[]
for impl in ['ref','avx2']:
 r={'implementation':impl,'profile':'128'}
 for st in steps:
  p=f'{ROOT}/build/keygen_{impl}_{st}.bin'
  if os.path.exists(p):
   b=open(p,'rb').read(); r[st+'_sha256']=hashlib.sha256(b).hexdigest()
  else:
   r[st+'_sha256']='MISSING'
 rows.append(r)
outt=f'{ROOT}/build/mamba_sign_t_trace_real.txt'; outc=f'{ROOT}/build/mamba_sign_t_trace_real.csv'
with open(outt,'w') as f:
 for st in steps:
  a=rows[0][st+'_sha256']; b=rows[1][st+'_sha256']; eq='YES' if a==b else 'NO'
  f.write(f'{st}: ref={a} avx2={b} equal={eq}\n')
with open(outc,'w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=['implementation','profile']+[s+'_sha256' for s in steps]); w.writeheader(); w.writerows(rows)
print(open(outt).read())
