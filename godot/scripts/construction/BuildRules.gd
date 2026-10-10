extends RefCounted
const JointModel = preload("res://scripts/physics/JointModel.gd")
## Server should be sole authority for these rules once network play is enabled.
static func try_join(method: String, skill: float, budget_seconds: float, materials_available: bool) -> Dictionary:
    if not materials_available:
        return {"ok": false, "reason": "No fastening materials", "time": 0.0}
    if not JointModel.valid(method):
        return {"ok": false, "reason": "Unknown joining method", "time": 0.0}
    var seconds: float = JointModel.construction_seconds(method, skill)
    if seconds > budget_seconds:
        return {"ok": false, "reason": "Build timer expired", "time": 0.0}
    return {"ok": true, "reason": "Joint created", "time": seconds}
