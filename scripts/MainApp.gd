extends Node2D

# Referência a nós importantes
@onready var consoleui = $UI/Console # Referencie o Nó do console. (RichTextLabel)
@onready var httprequest = $SearchData # Referencie o Nó das requisições para busca inicial de dados. (HttpRequest)
@onready var IDline = $UI/ID # Referencie o Nó do Input de ID. (LineEdit)

# Variáveis para uso em todo o script.
var data; # Variável que terá o valor do arquivo de configurações inteiro.
var token; # Variável que detem o valor do token usado nas requisições, tanto no momento de leitura quanto de escrita.
var output; # Variável que detem o valor do estado do output
var Useridformated; # Variável que detem o valor do ID do usuário, proveniente do input do usuário.
var outputrequest; # Varíavel que detem o documento JSON bruto, retornado pelo servidor após a requisição.
var avatarid; # Variável que detem o valor do ID do avatar, retornado pelo servidor após a requisição.
var bannerid;# Variável que detem o valor do ID do banner, retornado pelo servidor após a requisição.
var avatarurl; # Variável que detem o valor da url final do avatar, geradao pela função mountfinalurl().
var avataranimatedurl; # Variável que detem o valor da url final do avatar animado, geradao pela função mountfinalurl().
var bannerurl; # Variável que detem o valor da url final do banner, geradao pela função mountfinalurl().
var banneranimatedurl; # Variável que detem o valor da url final do banner animado, geradao pela função mountfinalurl().
var ValidURL; # Variável que detem o valor que determina se um link é valido ou não.

signal ContinueValidation # Declaração do valor do sinal para a lógica de validação de URL's.

func _ready() -> void:
	SignalManager.connect("ReadComplete", data_handler)
	SignalManager.AppStarted.emit()

func data_handler():
	output = FileManager.json_dictionary["output"]
	token = FileManager.json_dictionary["token"]
	changeoutputbuttonstate()

# Função para adicionar logs ao console
func add_message(message: String) -> void:
	consoleui.text += (message + "\n")
	consoleui.scroll_to_line(consoleui.get_line_count() - 1)

# Função que limpa o console, atrubuindo-a uma string vazia
func _on_clear_console_button_pressed() -> void:
	consoleui.text = ""

# Função que captura o estado de um CheckButton e o escreve em um arquivo de configurações para que seu estado seja lembrado.
func _on_show_output_button_toggled(toggled_on: bool):
		match toggled_on: # Match que descobre se o botão está em posição 'true' ou 'false'.
			true:
				output = true  # Atribuindo a valor 'true' antes da escrita.
			false:
				output = false # Atribuindo a valor 'false' antes da escrita.
		
		FileManager.write_json("output", output)

func changeoutputbuttonstate() -> void:
	if output == true:
		$UI/Control/ShowOutputButton.button_pressed = true

# Abre a UI para inserção do token
func _on_add_token_button_pressed() -> void:
	$UI/InsertTokenScreen.visible = true

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
		"Authorization: Bot %s" % token,
		 "Content-Type: application/json"
]
		var idinput = IDline.text
		Useridformated = idinput
		var url = "https://discord.com/api/v10/users/%s" % idinput
		httprequest.request(url, headers)

func _on_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	outputrequest = body.get_string_from_utf8()
	if output == true and not outputrequest == null:
		add_message(outputrequest)
		
	var json = JSON.new()
	if not outputrequest == null:
		var info = json.parse(outputrequest)
		if info == OK:
			var requestdata = json.get_data()
			if response_code != 200: # Se a requisição não for um sucesso prossiga para descobrir mais erros.
				if response_code == 401: # Caso o Http code for 401 (Não autorizado avise o usuário!
					add_message("401 Não autorizado! (Verifique o token)")
					return
				else:
					add_message("O servidor retornou um erro! Tente novamente em alguns instantes.")
					return
			avatarid = requestdata.get("avatar", "")
			bannerid = requestdata.get("banner", "")
			mountfinalurl()
			OS.alert("Validando URL's aguarde alguns instantes!", "Aguarde!" )
		else:
			OS.alert("Ocorreu um erro ao parsear a resposta do servidor!", "ERRO!")
			add_message("parseoutputrequest(): Ocorreu um erro ao parsear a resposta do servidor!")
			return

func mountfinalurl():
	var newHttpRequest = $ValidateURL

	avatarurl = "https://cdn.discordapp.com/avatars/%s/%s.png?size=2048" % [Useridformated, avatarid]
	newHttpRequest.request(avatarurl)
	await ContinueValidation
	if ValidURL == true:
		add_message(avatarurl)
	else:
		add_message("O usuário não possui um avatar personalizado!")
	
	avataranimatedurl = "https://cdn.discordapp.com/avatars/%s/%s.gif?size=2048" % [Useridformated, avatarid]
	newHttpRequest.request(avataranimatedurl)
	await ContinueValidation
	if ValidURL == true:
		add_message(avataranimatedurl)
	else:
		add_message("O usuário não possui um avatar animado!")
		
	bannerurl = "https://cdn.discordapp.com/banners/%s/%s.png?size=2048" % [Useridformated, bannerid]
	newHttpRequest.request(bannerurl)
	await ContinueValidation
	if ValidURL == true:
		add_message(bannerurl)
	else:
		add_message("O usuário não possui um banner personalizado!")
	
	banneranimatedurl = "https://cdn.discordapp.com/banners/%s/%s.gif?size=2048" % [Useridformated, bannerid]
	newHttpRequest.request(banneranimatedurl)
	await ContinueValidation
	if ValidURL == true:
		add_message(banneranimatedurl)
	else: 
		add_message("O usuário não possui um banner animado!")

	
func _on_validate_url_request_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	
	if response_code == 200: # Verifica se o servidor retornou status de sucesso quando a URL foi requisitada.
		ValidURL = true
	else:
		ValidURL = false

	emit_signal("ContinueValidation")
