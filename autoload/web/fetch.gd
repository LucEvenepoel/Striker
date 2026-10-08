extends Node

@onready var http := HTTPRequest.new()

const DISCORD_PROFILES_STATIC_RESOURCE_API: String = "https://cdn.discordapp.com"
const DISCORD_USER_STATIC_API: String = "https://discord.com/api/v10/users/"
const STRIKER_USER_AGENT: String = "DiscordBot (https://github.com/LucEvenepoel/Striker, v1.0)"

var actual_dictionary = FileManager.actual_dictionary

var avatar_bag: Dictionary;
var banner_bag: Dictionary;
var user_bag: Dictionary = {
	"UserID": "",
	"AvatarID": "",
	"BannerID": ""
}

func _ready() -> void:
	SignalManager.search_user.connect(fetch)
	add_child(http)
	http.request_completed.connect(finish_fetch)
	http.timeout = 15

func fetch(UserID: String) -> void:
	if actual_dictionary["Token"] != "":
		user_bag["UserID"] = UserID
		var url = DISCORD_USER_STATIC_API + user_bag["UserID"]
		var headers = [
			"Authorization: Bot %s" % actual_dictionary["Token"],
			"Content-Type: application/json",
			"User-Agent: %s" % STRIKER_USER_AGENT
		]
		http.request(url, headers)
	else:
		SignalManager.console_log.emit("O Striker não pode fazer a requisição, Token vazio?")
		SignalManager.search_finshed.emit()
		return 

func finish_fetch(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var data = body.get_string_from_utf8()
	var json = JSON.new()
	
	if (data != ""):
		if (FileManager.actual_dictionary["ShowAPIResponse"]):
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
			
func mount_urls() -> void:
	avatar_bag = {
		"default_discord_static_avatar_url": "%s/avatars/%s/%s.png?size=2048" % [DISCORD_PROFILES_STATIC_RESOURCE_API, user_bag["UserID"], user_bag["AvatarID"]],
		"default_discord_animated_avatar_url": "%s/avatars/%s/%s.gif?size=2048" % [DISCORD_PROFILES_STATIC_RESOURCE_API, user_bag["UserID"], user_bag["AvatarID"]]
	}
	
	banner_bag = {
		"default_discord_static_banner_url": "%s/banners/%s/%s.png?size=2048" % [DISCORD_PROFILES_STATIC_RESOURCE_API, user_bag["UserID"], user_bag["BannerID"]],
		"default_discord_animated_banner_url": "%s/banners/%s/%s.gif?size=2048" % [DISCORD_PROFILES_STATIC_RESOURCE_API, user_bag["UserID"], user_bag["BannerID"]]
	}
	verify_urls()

func verify_urls() -> void:
	if user_bag["AvatarID"] == null && user_bag["BannerID"] == null:
		SignalManager.console_log.emit("O usuário não possui nenhum Avatar/Banner")
		SignalManager.search_finshed.emit()

	if !(user_bag["AvatarID"] == null):
		if (user_bag["AvatarID"].begins_with("a_")):
			for url in avatar_bag:
				SignalManager.console_log.emit(avatar_bag[url])
		else:
			SignalManager.console_log.emit(avatar_bag["default_discord_static_avatar_url"])
		
	if !(user_bag["BannerID"] == null):
		if (user_bag["BannerID"].begins_with("a_")):
			for url in banner_bag:
				SignalManager.console_log.emit(banner_bag[url])
		else:
			SignalManager.console_log.emit(banner_bag["default_discord_static_banner_url"])
			
	SignalManager.search_finshed.emit()
