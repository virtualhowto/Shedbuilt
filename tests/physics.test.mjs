import test from 'node:test';
import assert from 'node:assert/strict';
import {METHODS,capacity,buildSeconds,utilization,evaluateImpact,acceleration,calculateBuild,step,initialState} from '../web-lab/physics.mjs';

test('weld stronger than bolts stronger than tape at same quality',()=>{
  assert.ok(capacity('weld',.9).shear>capacity('bolts',.9).shear);
  assert.ok(capacity('bolts',.9).shear>capacity('tape',.9).shear);
});
test('tape fast, welding slow, skill reduces time',()=>{
  assert.ok(buildSeconds('tape')<buildSeconds('bolts'));
  assert.ok(buildSeconds('bolts')<buildSeconds('weld'));
  assert.ok(buildSeconds('weld',1.4)<buildSeconds('weld',.8));
});
test('impact differentiates weak/strong fasteners',()=>{
  assert.equal(evaluateImpact({method:'tape',quality:.85,mass:85,speed:10}).failed,true);
  assert.equal(evaluateImpact({method:'weld',quality:.85,mass:85,speed:10}).failed,false);
});
test('overbudget work remains incomplete',()=>{
  assert.equal(calculateBuild({method:'weld',budget:15}).complete,false);
  assert.equal(calculateBuild({method:'tape',budget:15,alignment:0}).complete,false); // 6 + 10 sec
});
test('alignment increases rolling losses',()=>{
  assert.ok(acceleration({alignment:0,speed:7})>acceleration({alignment:6,speed:7}));
});
test('strong joints finish course with same initial conditions',()=>{
  let state=initialState();
  for(let i=0;i<9000&&!state.done;i++)state=step(state,{method:'weld',quality:.85,mass:85,alignment:1});
  assert.equal(state.done,true);assert.equal(state.failed,false);assert.ok(state.distance>=430);
});
test('taped axle will fail when shock arrives',()=>{
  let state=initialState();
  for(let i=0;i<9000&&!state.done;i++)state=step(state,{method:'tape',quality:.85,mass:85,alignment:1});
  assert.equal(state.failed,true);assert.ok(state.events.length>=1);
});
test('joint utilization scales with quality and force',()=>{
  assert.ok(utilization('bolts',.5,{shear:1000})>utilization('bolts',1,{shear:1000}));
  assert.ok(utilization('tape',.8,{shear:1500})>1);
});
test('bad method rejected',()=>assert.throws(()=>capacity('glue')));
