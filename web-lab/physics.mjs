/** Shedbuilt physics LAB, simplified 1D rolling dynamics and impact-load joint evaluation. */
export const METHODS = Object.freeze({
  tape: { label: 'Duct tape', shear: 300, tension: 140, moment: 45, time: 6, icon: 'TAPE' },
  bolts: { label: 'Bolted bracket', shear: 3500, tension: 2800, moment: 750, time: 25, icon: 'BOLT' },
  weld: { label: 'Welded steel', shear: 6500, tension: 4600, moment: 1200, time: 40, icon: 'WELD' },
});
export function finite(v, fallback=0) { return Number.isFinite(v) ? v : fallback; }
export function clamp(n, lo, hi) { return Math.min(hi, Math.max(lo, n)); }
export function buildSeconds(method, skill=1) {
  if (!METHODS[method]) throw new Error('Unknown method');
  return METHODS[method].time / clamp(finite(skill,1),0.5,1.5);
}
export function capacity(method, quality=1) {
  if (!METHODS[method]) throw new Error('Unknown method');
  const q=clamp(finite(quality,1),0.1,1);
  const m=METHODS[method];
  return {shear:m.shear*q,tension:m.tension*q,moment:m.moment*q};
}
export function utilization(method, quality, {shear=0,tension=0,moment=0}={}) {
  const c=capacity(method,quality);
  return Math.hypot(finite(shear)/c.shear, finite(tension)/c.tension, finite(moment)/c.moment);
}
export function evaluateImpact({method='tape',quality=0.85,mass=70,speed=10,stopTime=0.12}) {
  const shear=clamp(finite(mass),1,250)*Math.abs(finite(speed))*0.4/clamp(finite(stopTime,0.12),0.01,1);
  const ratio=utilization(method,quality,{shear});
  return {shear,ratio,failed:ratio>=1};
}
/** Gravity, slope, aero drag and rolling friction. Uphill and powered machines are not supported. */
export function acceleration({mass=70,speed=0,slopeDegrees=9,alignment=0,rollingCoefficient=0.018,cdA=0.45}) {
  const g=9.81, theta=clamp(finite(slopeDegrees,9),0,45)*Math.PI/180;
  const rolling=clamp(rollingCoefficient,0,0.2)+clamp(Math.abs(alignment),0,10)*0.003;
  return g*Math.sin(theta) - g*Math.cos(theta)*rolling - 0.5*1.225*cdA*speed*Math.abs(speed)/clamp(mass,1,300);
}
export function initialState() {return {distance:0,speed:0,time:0,failed:false,done:false,lastImpact:null,events:[],nextBump:0};}
const BUMPS=[55,148,284];
export function step(state,options,dt=1/60) {
  if (state.done) return state;
  dt=clamp(finite(dt,1/60),0,0.05);
  const o={...options,mass:clamp(finite(options.mass,70),20,180)};
  const speed=Math.max(0,state.speed+acceleration({...o,speed:state.speed})*dt);
  const dist=state.distance+speed*dt;
  const next={...state,speed,distance:dist,time:state.time+dt};
  if (next.nextBump < BUMPS.length && dist>=BUMPS[next.nextBump]) {
    const impact=evaluateImpact({...o,speed});
    next.lastImpact=impact;
    next.events=[...state.events,{distance:dist,speed, ...impact}];
    next.nextBump++;
    if (impact.failed) {next.failed=true;next.done=true;}
  }
  if (dist>=430 || next.time>=120) next.done=true;
  return next;
}
export function calculateBuild({method='tape',skill=1,budget=600,prep=0.85,alignment=0}={}) {
  const seconds=buildSeconds(method,skill)+10+Math.max(0,Math.abs(alignment))*5;
  const complete=seconds<=budget;
  const quality=clamp(prep*(0.88+0.12*clamp(skill,0.5,1.5))*(1-0.05*Math.abs(alignment)),0.1,1);
  return {seconds,complete,remaining:Math.max(0,budget-seconds),quality};
}
