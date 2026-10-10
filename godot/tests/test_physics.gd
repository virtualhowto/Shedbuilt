extends SceneTree
const Joint = preload("res://scripts/physics/JointModel.gd")
const Build = preload("res://scripts/construction/BuildRules.gd")

func _initialize() -> void:
    var fail := false
    if not Joint.construction_seconds("tape") < Joint.construction_seconds("weld"):
        fail = true
    if not Joint.load_utilization("tape", 1.0, 1000.0) > 1.0:
        fail = true
    if not Joint.load_utilization("weld", 1.0, 1000.0) < 1.0:
        fail = true
    if Build.try_join("weld", 1.0, 10.0, true)["ok"]:
        fail = true
    if not Build.try_join("bolts", 1.0, 30.0, true)["ok"]:
        fail = true
    if Joint.construction_seconds("unknown") != INF:
        fail = true
    if fail:
        push_error("Shedbuilt Godot physics test FAILED")
        quit(1)
    else:
        print("PASS: Godot joint capacity and construction fixtures")
        quit(0)
