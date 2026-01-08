extends Node




const ADDRESS = "localhost"
const PORT = 42069

const Player = preload("res://scenes/player.tscn")
var enet_peer: ENetMultiplayerPeer


# start server
func _on_host_pressed() -> void:
	enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player)
	
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()

# connect
func _on_join_pressed() -> void:
	enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	if multiplayer.is_server():
		var player = Player.instantiate()
		#player.set_multiplayer_authority(peer_id)
		player.name = str(peer_id)
		add_child(player)
		
		print("player spawned: ", peer_id)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


func _on_multiplayer_spawner_spawned(node):
	pass
	
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	
