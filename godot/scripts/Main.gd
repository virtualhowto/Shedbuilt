extends Node3D
## Procedural 3D construction + downhill joint-failure PoC. This is not a complete vehicle model.
const JointModel = preload("res://scripts/physics/JointModel.gd")
const BuildRules = preload("res://scripts/construction/BuildRules.gd")
const VERSION := "0.1.0-lab"
var method: String = "tape"
var time_budget: float = 90.0
var skill: float = 1.0
var build_quality: float = 0.85
var released := false
var broken := false
var impact_registered := false
var chassis: RigidBody3D
var axle: RigidBody3D
var joint: PinJoint3D
var camera: Camera3D
var info: Label
var camera_first_person := false
var output_text := "Select a joining method, attach, then release."

func _ready() -> void:
    if GameNetwork.active:
        # Visual world still exists on headless server, but no UI required.
        pass
    _make_environment()
    _make_vehicle()
    if not DisplayServer.get_name() == "headless":
        _make_ui()
    _update_info()

func _make_environment() -> void:
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-50, -25, 0)
    light.light_energy = 1.7
    add_child(light)
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.51, 0.63, 0.66)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.5, 0.53, 0.52)
    env.ambient_light_energy = 0.65
    world.environment = env
    add_child(world)
    # Falling toward +Z; positive X rotation of the ramp drops ground as Z increases.
    var ramp := StaticBody3D.new()
    ramp.name = "Hill"
    ramp.rotation.x = 0.115
    ramp.position = Vector3(0, 0, 15)
    add_child(ramp)
    _make_box(ramp, Vector3(17, 0.55, 95), Color(0.25, 0.24, 0.22), true)
    for side in [-1, 1]:
        for i in range(9):
            var scrap := StaticBody3D.new()
            scrap.position = Vector3(side * (10.0 + float(i % 3) * 1.6), 0.0, -28.0 + i * 9.0)
            scrap.rotation.y = float(i) * 0.27
            add_child(scrap)
            _make_box(scrap, Vector3(1.7 + float(i % 3), 1.0, 1.5), Color(0.38, 0.26, 0.2), true)
    var bump := StaticBody3D.new()
    bump.name = "RoadBump"
    bump.position = Vector3(0, 0.6, 14)
    add_child(bump)
    _make_box(bump, Vector3(4.2, 0.28, 0.45), Color(0.35, 0.31, 0.27), true)
    camera = Camera3D.new()
    camera.name = "WorkshopCamera"
    camera.current = true
    camera.fov = 72
    add_child(camera)

func _make_box(parent: Node3D, dimensions: Vector3, colour: Color, collider: bool) -> void:
    var mesh := MeshInstance3D.new()
    var geo := BoxMesh.new()
    geo.size = dimensions
    mesh.mesh = geo
    var material := StandardMaterial3D.new()
    material.albedo_color = colour
    material.roughness = 0.9
    mesh.material_override = material
    parent.add_child(mesh)
    if collider:
        var shape := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = dimensions
        shape.shape = box
        parent.add_child(shape)

func _make_vehicle() -> void:
    released = false
    broken = false
    impact_registered = false
    if is_instance_valid(chassis):
        chassis.queue_free()
    if is_instance_valid(axle):
        axle.queue_free()
    if is_instance_valid(joint):
        joint.queue_free()
    chassis = RigidBody3D.new()
    chassis.name = "Chassis"
    chassis.mass = 65.0
    chassis.position = Vector3(0, 5.3, -15)
    chassis.freeze = true
    chassis.contact_monitor = true
    chassis.max_contacts_reported = 10
    add_child(chassis)
    _make_box(chassis, Vector3(1.7, 0.38, 2.7), Color(0.36, 0.26, 0.2), true)
    axle = RigidBody3D.new()
    axle.name = "FrontAxle"
    axle.mass = 6.0
    axle.position = chassis.position + Vector3(0, -0.05, 1.25)
    axle.freeze = true
    add_child(axle)
    _make_box(axle, Vector3(2.3, 0.2, 0.35), Color(0.33, 0.39, 0.4), true)
    for x in [-1.12, 1.12]:
        var wheel := MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.49
        cylinder.bottom_radius = 0.49
        cylinder.height = 0.2
        wheel.mesh = cylinder
        wheel.rotation.z = PI / 2.0
        wheel.position = Vector3(x, -0.1, 0)
        var rubber := StandardMaterial3D.new()
        rubber.albedo_color = Color(0.10, 0.10, 0.11)
        wheel.material_override = rubber
        axle.add_child(wheel)
    # Rear wheel visual only in this PoC: not yet rolling tyre bodies.
    for x in [-1.05, 1.05]:
        var wheel := MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.49
        cylinder.bottom_radius = 0.49
        cylinder.height = 0.2
        wheel.mesh = cylinder
        wheel.rotation.z = PI / 2.0
        wheel.position = Vector3(x, -0.1, -1.05)
        chassis.add_child(wheel)
    _install_joint()

func _install_joint() -> void:
    if is_instance_valid(joint):
        joint.queue_free()
    joint = PinJoint3D.new()
    joint.name = "FrontAxleMount"
    add_child(joint)
    joint.global_position = chassis.global_position + Vector3(0, 0, 1.25)
    joint.node_a = joint.get_path_to(chassis)
    joint.node_b = joint.get_path_to(axle)
    joint.exclude_nodes_from_collision = true

func _make_ui() -> void:
    var canvas := CanvasLayer.new()
    add_child(canvas)
    var panel := PanelContainer.new()
    panel.position = Vector2(20, 20)
    canvas.add_child(panel)
    var column := VBoxContainer.new()
    column.custom_minimum_size.x = 365
    panel.add_child(column)
    var title := Label.new()
    title.text = "SHEDBUILT / JOINT LAB  " + VERSION
    column.add_child(title)
    info = Label.new()
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.custom_minimum_size.y = 105
    column.add_child(info)
    for option in ["tape", "bolts", "weld"]:
        var button := Button.new()
        button.text = "Attach with %s" % option.to_upper()
        button.pressed.connect(_on_build.bind(option))
        column.add_child(button)
    for action in ["Release cart", "Reset run", "Switch camera"]:
        var button := Button.new()
        button.text = action
        button.pressed.connect(_on_action.bind(action))
        column.add_child(button)

func _on_build(selected: String) -> void:
    if released:
        output_text = "Reset before changing joints."
        _update_info()
        return
    var result: Dictionary = BuildRules.try_join(selected, skill, time_budget, true)
    if not result["ok"]:
        output_text = str(result["reason"])
        _update_info()
        return
    time_budget -= float(result["time"])
    method = selected
    build_quality = 0.85
    _install_joint()
    output_text = "%s joint built in %.0fs." % [method, result["time"]]
    _update_info()

func _on_action(action: String) -> void:
    match action:
        "Release cart":
            released = true
            chassis.freeze = false
            axle.freeze = false
            output_text = "Released. Watch the front axle mount."
        "Reset run":
            time_budget = 90.0
            _make_vehicle()
            output_text = "Vehicle reset."
        "Switch camera":
            camera_first_person = not camera_first_person
    _update_info()

func _process(_delta: float) -> void:
    if not is_instance_valid(chassis) or not is_instance_valid(camera):
        return
    var focus := chassis.global_position
    if camera_first_person:
        camera.global_position = focus + Vector3(0, 0.9, 0.3)
        camera.look_at(focus + Vector3(0, 0.1, 12), Vector3.UP)
    else:
        camera.global_position = camera.global_position.lerp(focus + Vector3(5, 6, -13), 0.075)
        camera.look_at(focus + Vector3(0, 0.2, 4), Vector3.UP)
    if released:
        _update_info()

func _physics_process(_delta: float) -> void:
    if not released or broken or impact_registered:
        return
    # Deterministic diagnostic impact event at the test marker, NOT true contact force telemetry.
    if chassis.global_position.z >= 12.0:
        impact_registered = true
        var speed: float = chassis.linear_velocity.length()
        var measured_force: float = chassis.mass * speed * 0.4 / 0.12
        if JointModel.impact_failure(method, build_quality, chassis.mass, speed):
            broken = true
            joint.queue_free()
            output_text = "FAILURE: %s joint failed at estimated %.0f N." % [method, measured_force]
        else:
            output_text = "PASS: %s joint survived estimated %.0f N." % [method, measured_force]
        _update_info()

func _update_info() -> void:
    if not is_instance_valid(info):
        return
    var speed := 0.0
    if is_instance_valid(chassis):
        speed = chassis.linear_velocity.length() * 3.6
    info.text = "%s\nMethod: %s | Build budget: %.0fs\nCart speed: %.1f km/h | Axle: %s\nView: %s" % [output_text, method, time_budget, speed, "BROKEN" if broken else "attached", "First" if camera_first_person else "Third"]
