extends Node

var API_URL := "http://127.0.0.1:8000/games"
var player_id := "Firebase.Auth.auth.localid  # ID del usuario" 

# 📌 Guardar partida en el servidor
func save_game_named(name: String):
	var save_data = {
		"life": Player.player_life,
		"gold": Player.player_gold,
		"days": Player.wave,
		"unlocked_towers": Player.unlocked_towers,
		"difficulty": Player.dificulty,
		"towers": []
	}

	var request = HTTPRequest.new()
	add_child(request)
	request.request(API_URL + "/" + player_id + "/" + name, [], HTTPClient.METHOD_POST, JSON.stringify(save_data))

# 📌 Cargar partida desde el servidor
func load_game_named(name: String):
	var request = HTTPRequest.new()
	add_child(request)
	request.request(API_URL + "/" + player_id + "/" + name, [], HTTPClient.METHOD_GET)

	await request.request_completed
	var response = JSON.parse_string(request.get_body())
	
	if response.has("data"):
		var save_data = JSON.parse_string(response["data"])
		Player.player_life = save_data["life"]
		Player.player_gold = save_data["gold"]
		Player.wave = save_data["days"]
		Player.unlocked_towers = save_data["unlocked_towers"]
		Player.dificulty = save_data["difficulty"]
		print("✅ Partida cargada correctamente:", name)
		return true
	else:
		print("❌ No se encontró la partida:", name)
		return false

# 📌 Eliminar partida
func delete_game_named(name: String):
	var request = HTTPRequest.new()
	add_child(request)
	request.request(API_URL + "/" + player_id + "/" + name, [], HTTPClient.METHOD_DELETE)
	print("🗑️ Partida eliminada:", name)
