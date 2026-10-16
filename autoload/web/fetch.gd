extends Node

@onready var http := HTTPRequest.new()

const DISCORD_DEFAULT_CDN: String = "https://cdn.discordapp.com"
const DISCORD_DEFAULT_API: String = "https://discord.com/api/v10/users/"
const STRIKER_USER_AGENT: String = "DiscordBot (https://github.com/LucEvenepoel/Striker, v1.0)"

var actual_dictionary = FS.actual_dictionary
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
			SignalManager.console_log.emit(tr("ERR_INIT_REQUEST_FAILED") % err)
			SignalManager.search_finshed.emit()
			return
			
		return OK
	else:
		SignalManager.console_log.emit(tr("ERR_CANT_MAKE_REQUEST"))
		SignalManager.search_finshed.emit()
		return 

func finish_fetch(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		SignalManager.console_log.emit(tr("ERR_NET_OR_TIMEOUT") % result)
		SignalManager.search_finshed.emit()
		return
		
	var data = body.get_string_from_utf8()
	var json = JSON.new()
	
	if (data != ""):
		if (FS.actual_dictionary["ShowRequestRawData"]): # It returns a bool value
			SignalManager.console_log.emit(data)
		
		var info = json.parse(data)
		if info == OK:
			var requestdata = json.get_data()
			if response_code == 200:
				user_bag["AvatarID"] = requestdata.get("avatar", "")
				user_bag["BannerID"] = requestdata.get("banner", "")
				mount_urls()
			else:
				SignalManager.console_log.emit(tr("SERVER_HTTP_CODE_REPORT") % [requestdata])
				SignalManager.search_finshed.emit()
				return
		else:
			SignalManager.console_log.emit(tr("ERR_PARSE_RESPONSE"))
			SignalManager.search_finshed.emit()
			return
	else:
		SignalManager.console_log.emit(tr("ERR_CANT_ACCESS_SERVER_RESPONSE"))
		SignalManager.search_finshed.emit()
		return

func mount_urls() -> void:
	if user_bag["AvatarID"] == null && user_bag["BannerID"] == null:
		SignalManager.console_log.emit(tr("ALERT_USER_WITHOUT_AVATAR_OR_BANNER"))
		SignalManager.search_finshed.emit()
		return
		
	if !(user_bag["AvatarID"] == null):
		var base_avatar_url = "%s/avatars/%s/%s" % [DISCORD_DEFAULT_CDN, user_bag["UserID"], user_bag["AvatarID"]]

		SignalManager.console_show_link.emit(base_avatar_url + ".png?size=2048", tr("UI_STATIC_AVATAR"))
		if (user_bag["AvatarID"].begins_with("a_")):
			SignalManager.console_show_link.emit(base_avatar_url + ".gif?size=2048", tr("UI_ANIMATED_AVATAR"))
			
	if !(user_bag["BannerID"] == null):
		var base_banner_url = "%s/banners/%s/%s" % [DISCORD_DEFAULT_CDN, user_bag["UserID"], user_bag["BannerID"]]

		SignalManager.console_show_link.emit(base_banner_url + ".png?size=2048", tr("UI_STATIC_BANNER"))
		if (user_bag["BannerID"].begins_with("a_")):
			SignalManager.console_show_link.emit(base_banner_url + ".gif?size=2048", tr("UI_ANIMATED_BANNER"))

	SignalManager.search_finshed.emit()
