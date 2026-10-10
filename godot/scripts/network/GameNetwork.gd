extends Node
## Minimal development-only private lobby handshake. NOT production authorization.
const DEFAULT_PORT := 9080
var authorized: Dictionary = {}
var active: bool = false
var last_join_ms: Dictionary = {}

func _ready() -> void:
    if OS.has_feature("dedicated_server") or "--server" in OS.get_cmdline_user_args():
        var key := _get_lobby_key()
        if key.length() < 12:
            push_error("Server requires SHEDBUILT_LOBBY_KEY of at least 12 characters")
            get_tree().quit(2)
            return
        var port := DEFAULT_PORT
        for arg in OS.get_cmdline_user_args():
            if arg.begins_with("--port="):
                port = int(arg.get_slice("=", 1))
        var server := WebSocketMultiplayerPeer.new()
        var code := server.create_server(port)
        if code != OK:
            push_error("Could not listen on WebSocket port %d" % port)
            get_tree().quit(3)
            return
        multiplayer.multiplayer_peer = server
        multiplayer.peer_connected.connect(_peer_connected)
        multiplayer.peer_disconnected.connect(_peer_disconnected)
        active = true
        print("SHEDBUILT game network listening on port %d" % port)

func _peer_connected(id: int) -> void:
    authorized[id] = false

func _peer_disconnected(id: int) -> void:
    authorized.erase(id)
    last_join_ms.erase(id)

@rpc("any_peer", "call_remote", "reliable")
func request_join(lobby_key: String) -> void:
    if not multiplayer.is_server() or not active:
        return
    var id := multiplayer.get_remote_sender_id()
    if not authorized.has(id):
        return
    var now := Time.get_ticks_msec()
    var prior := int(last_join_ms.get(id, -2000))
    if now - prior < 1000:
        return
    last_join_ms[id] = now
    var expected := _get_lobby_key()
    var ok := lobby_key.length() >= 12 and lobby_key == expected
    authorized[id] = ok
    join_result.rpc_id(id, ok)
    if not ok:
        print("Rejected unauthorized peer: %d" % id)

@rpc("authority", "call_remote", "reliable")
func join_result(_ok: bool) -> void:
    # Client-side response hook; wire to production lobby UI later.
    pass

@rpc("any_peer", "call_remote", "reliable")
func request_build(method: String) -> void:
    if not multiplayer.is_server() or not active:
        return
    var id := multiplayer.get_remote_sender_id()
    if not bool(authorized.get(id, false)):
        return
    if not method in ["tape", "bolts", "weld"]:
        return
    # Server-side inventory, positions, phase, tool and clock checks are TODO.
    # No build is actually applied: deliberately avoids an insecure authority bypass.
    print("Validated permitted method from %d; no mutation until authorizer is complete" % id)

func _get_lobby_key() -> String:
    # Docker Swarm secret preferred; environment only for local private development.
    if FileAccess.file_exists("/run/secrets/shedbuilt_lobby_key"):
        return FileAccess.get_file_as_string("/run/secrets/shedbuilt_lobby_key").strip_edges()
    return OS.get_environment("SHEDBUILT_LOBBY_KEY")
