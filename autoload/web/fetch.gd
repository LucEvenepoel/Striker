extends Node

@onready var http := HTTPRequest.new()

const DISCORD_DEFAULT_CDN: String = "https://cdn.discordapp.com"
const DISCORD_DEFAULT_API: String = "https://discord.com/api/v10/users/"
const STRIKER_USER_AGENT: String = "DiscordBot (https://github.com/LucEvenepoel/Striker, v1.0)"

var actual_dictionary = FileManager.actual_dictionary
var user_bag: Dictionary = { "UserID": "", "AvatarID": "","BannerID": ""}

func _ready() -> void:
	add_child(http)
	http.request_completed.connect(finish_fetch)
	http.timeout = 15

func fetch(UserID: String):
	if actual_dictionary["Token"] != "":
		user_bag["UserID"] = UserID
		var url = DISCORD_DEFAULT_API + user_bag["UserID"]
		var headers = [
			"Authorization: Bot %s" % actual_dictionary["Token"],
			"Content-Type: application/json",
			"User-Agent: %s" % STRIKER_USER_AGENT
		]
		var err := http.request(url, headers)
		if err != OK:
			SignalManager.console_log.emit("Falha ao iniciar a requisição (erro %d)." % err)
			SignalManager.search_finshed.emit()
			return
			
		return OK
	else:
		SignalManager.console_log.emit("O Striker não pode fazer a requisição, Token vazio?")
		SignalManager.search_finshed.emit()
		return 

func finish_fetch(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		SignalManager.console_log.emit("Falha de rede ou tempo esgotado (código %d)." % result)
		SignalManager.search_finshed.emit()
		return
		
	var data = body.get_string_from_utf8()
	var json = JSON.new()
	
	if (data != ""):
		if (FileManager.actual_dictionary["ShowAPIResponse"]): # It returns a bool value
			SignalManager.console_log.emit(data)
		
		var info = json.parse(data)
		if info == OK:
			var requestdata = json.get_data()
			if response_code == 200:
				user_bag["AvatarID"] = requestdata.get("avatar", "")
				user_bag["BannerID"] = requestdata.get("banner", "")
				mount_urls()
			else:
				SignalManager.console_log.emit("Servidor: %s" % [requestdata])
				SignalManager.search_finshed.emit()
				return
		else:
			SignalManager.console_log.emit("Ocorreu um erro ao parsear a resposta do servidor!")
			SignalManager.search_finshed.emit()
			return
	else:
		SignalManager.console_log.emit("Ocorreu um erro ao acessar a resposta do servidor!")
		SignalManager.search_finshed.emit()
		return

func mount_urls() -> void:
	if user_bag["AvatarID"] == null && user_bag["BannerID"] == null:
		SignalManager.console_log.emit("O usuário não possui nenhum Avatar/Banner")
		SignalManager.search_finshed.emit()
		return
		
	if !(user_bag["AvatarID"] == null):
		var base_avatar_url = "%s/avatars/%s/%s" % [DISCORD_DEFAULT_CDN, user_bag["UserID"], user_bag["AvatarID"]]

		SignalManager.console_show_link.emit(base_avatar_url + ".png?size=2048", "Avatar Estático")
		if (user_bag["AvatarID"].begins_with("a_")):
			SignalManager.console_show_link.emit(base_avatar_url + ".gif?size=2048", "Avatar Animado")
			
	if !(user_bag["BannerID"] == null):
		var base_banner_url = "%s/banners/%s/%s" % [DISCORD_DEFAULT_CDN, user_bag["UserID"], user_bag["BannerID"]]

		SignalManager.console_show_link.emit(base_banner_url + ".png?size=2048", "Banner Estático")
		if (user_bag["BannerID"].begins_with("a_")):
			SignalManager.console_show_link.emit(base_banner_url + ".gif?size=2048", "Banner Animado")

	SignalManager.search_finshed.emit()
