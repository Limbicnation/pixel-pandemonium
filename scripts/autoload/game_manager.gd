extends Node

#region Game State
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
var current_state: GameState = GameState.MENU
#endregion

#region Player Reference
var player: PlayerController = null
#endregion

#region Game Data
var score: int = 0
var current_wave: int = 0
var crystals_collected: int = 0
var crystals_total: int = 0
#endregion

#region Signals
signal state_changed(new_state: GameState)
signal score_changed(new_score: int)
signal crystal_collected(count: int, total: int)
signal wave_started(wave_number: int)
signal game_over(won: bool)
#endregion

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Wait for scene to load and verify player registration
	await get_tree().process_frame
	if player == null:
		push_warning("GameManager: No player registered yet. Waiting...")
		# Give player scene time to call register_player()
		await get_tree().create_timer(0.1).timeout
		if player == null:
			push_error("GameManager: Player was never registered!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	
	match current_state:
		GameState.PLAYING:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameState.PAUSED:
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.MENU:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.GAME_OVER:
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	state_changed.emit(current_state)

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
	elif current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func register_player(player_node: PlayerController) -> void:
	player = player_node

func unregister_player() -> void:
	player = null

func start_game() -> void:
	score = 0
	current_wave = 0
	crystals_collected = 0
	change_state(GameState.PLAYING)

func game_over_screen(won: bool = false) -> void:
	change_state(GameState.GAME_OVER)
	game_over.emit(won)
