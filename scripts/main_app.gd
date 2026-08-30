extends Node2D

const MAIN_PATH = "user://"
@export var main_dictionary: Dictionary;

@onready var httprequest = $SearchData # Referencie o Nó das requisições para busca inicial de dados. (HttpRequest)
@onready var IDline = $Control/VBoxContainer/IDArea/ROW1/ID # Referencie o Nó do Input de ID. (LineEdit)
@onready var token_insert_popup: ConfirmationDialog = $InsertTokenPopup
@onready var search_data: HTTPRequest = $SearchData

var Useridformated;
var outputrequest;
var avatarid;
var bannerid;
var avatarurl;
var avataranimatedurl;
var bannerurl; 
var banneranimatedurl;
var ValidURL;

signal ContinueValidation # Declaração do valor do sinal para a lógica de validação de URL's.

func _ready() -> void:
	SignalManager.app_started.emit()
	
func _on_open_main_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(MAIN_PATH))

func _on_add_token_button_pressed() -> void:
	token_insert_popup.visible = true

# Botão que inicia a busca pelos avatares e banners
func _on_run_button_pressed() -> void:
	if IDline.text == "":
		OS.alert("O campo de ID não pode estar vazio.", "Alerta!")
		return
	elif not IDline.text.is_valid_int():
		OS.alert("O ID só pode conter números.", "Alerta!")
		return
	else:
		var headers = [
		"Authorization: Bot %s" % main_dictionary["Token"],
		 "Content-Type: application/json"
]
		var idinput = IDline.text
		Useridformated = idinput
		var url = "https://discord.com/api/v10/users/%s" % idinput
		httprequest.request(url, headers)

func _on_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	outputrequest = body.get_string_from_utf8()
	if main_dictionary["ShowAPIResponse"] == true and not outputrequest == null:
		SignalManager.log.emit(outputrequest)
		
	var json = JSON.new()
	if not outputrequest == null:
		var info = json.parse(outputrequest)
		if info == OK:
			var requestdata = json.get_data()
			if response_code != 200: # Se a requisição não for um sucesso prossiga para descobrir mais erros.
				if response_code == 401: # Caso o Http code for 401 (Não autorizado avise o usuário!
					SignalManager.log.emit("401 Não autorizado! (Verifique o token)")
					return
				else:
					SignalManager.log.emit("O servidor retornou um erro! Tente novamente em alguns instantes.")
					return
			avatarid = requestdata.get("avatar", "")
			bannerid = requestdata.get("banner", "")
			mountfinalurl()
			OS.alert("Validando URL's aguarde alguns instantes!", "Aguarde!" )
		else:
			OS.alert("Ocorreu um erro ao parsear a resposta do servidor!", "ERRO!")
			SignalManager.log.emit("parseoutputrequest(): Ocorreu um erro ao parsear a resposta do servidor!")
			return

func mountfinalurl():
	var newHttpRequest = $ValidateURL

	avatarurl = "https://cdn.discordapp.com/avatars/%s/%s.png?size=2048" % [Useridformated, avatarid]
	newHttpRequest.request(avatarurl)
	await ContinueValidation
	if ValidURL == true:
		SignalManager.log.emit(avatarurl)
	else:
		SignalManager.log.emit("O usuário não possui um avatar personalizado!")
	
	avataranimatedurl = "https://cdn.discordapp.com/avatars/%s/%s.gif?size=2048" % [Useridformated, avatarid]
	newHttpRequest.request(avataranimatedurl)
	await ContinueValidation
	if ValidURL == true:
		SignalManager.log.emit(avataranimatedurl)
	else:
		SignalManager.log.emit("O usuário não possui um avatar animado!")
		
	bannerurl = "https://cdn.discordapp.com/banners/%s/%s.png?size=2048" % [Useridformated, bannerid]
	newHttpRequest.request(bannerurl)
	await ContinueValidation
	if ValidURL == true:
		SignalManager.log.emit(bannerurl)
	else:
		SignalManager.log.emit("O usuário não possui um banner personalizado!")
	
	banneranimatedurl = "https://cdn.discordapp.com/banners/%s/%s.gif?size=2048" % [Useridformated, bannerid]
	newHttpRequest.request(banneranimatedurl)
	await ContinueValidation
	if ValidURL == true:
		SignalManager.log.emit(banneranimatedurl)
	else: 
		SignalManager.log.emit("O usuário não possui um banner animado!")

func _on_validate_url_request_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	
	if response_code == 200: # Verifica se o servidor retornou status de sucesso quando a URL foi requisitada.
		ValidURL = true
	else:
		ValidURL = false

	emit_signal("ContinueValidation")
