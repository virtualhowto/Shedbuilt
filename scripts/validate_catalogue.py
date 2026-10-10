#!/usr/bin/env python3
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
parts=json.loads((ROOT/'shared/parts.json').read_text())
challenge=json.loads((ROOT/'shared/challenges/big_hill.json').read_text())
joints=json.loads((ROOT/'shared/joints.json').read_text())
ids=set()
for p in parts['parts']:
 assert p['id'] not in ids, 'duplicate part id'
 ids.add(p['id'])
 assert p['mass_kg']>0
 assert 0<p['condition']<=1
 assert set(p['allow_methods']).issubset(joints['methods'])
for name,j in joints['methods'].items():
 assert name in ('tape','bolts','weld')
 assert all(j[k]>0 for k in ('shear_capacity_n','tension_capacity_n','moment_capacity_nm','base_seconds'))
assert challenge['build_seconds_min']<=challenge['build_seconds_default']<=challenge['build_seconds_max']
assert challenge['private_invite_only']
print(f"PASS: {len(ids)} parts, {len(joints['methods'])} joints, challenge schema")
