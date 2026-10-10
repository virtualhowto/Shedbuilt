extends RefCounted
## Simplified joint behaviour; inputs in N, Nm, seconds. Not engineering certification.
const DATA := {
    "tape": {"shear": 300.0, "tension": 140.0, "moment": 45.0, "time": 6.0},
    "bolts": {"shear": 3500.0, "tension": 2800.0, "moment": 750.0, "time": 25.0},
    "weld": {"shear": 6500.0, "tension": 4600.0, "moment": 1200.0, "time": 40.0},
}

static func valid(method: String) -> bool:
    return DATA.has(method)

static func construction_seconds(method: String, skill: float = 1.0) -> float:
    if not valid(method):
        return INF
    return DATA[method]["time"] / clampf(skill, 0.5, 1.5)

static func load_utilization(method: String, quality: float, shear_n: float, tension_n: float = 0.0, moment_nm: float = 0.0) -> float:
    if not valid(method):
        return INF
    var p: Dictionary = DATA[method]
    var q := clampf(quality, 0.1, 1.0)
    return sqrt(pow(shear_n / (p["shear"] * q), 2.0) + pow(tension_n / (p["tension"] * q), 2.0) + pow(moment_nm / (p["moment"] * q), 2.0))

static func impact_failure(method: String, quality: float, mass_kg: float, speed_ms: float, stop_time_s: float = 0.12) -> bool:
    var force_n := mass_kg * absf(speed_ms) * 0.4 / maxf(stop_time_s, 0.01)
    return load_utilization(method, quality, force_n) >= 1.0
