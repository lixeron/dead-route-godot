extends Node
## GameManager — Central state machine for Dead Route.
## Controls game flow: what screen is showing, what the player can do,
## and transitions between states.
##
## This is an AUTOLOAD (singleton) — access it from anywhere as GameManager.

# ── Game States ──────────────────────────────────────────
enum State {
	TITLE,           # Main menu
	INTRO,           # Text crawl + character creation
	PHASE_ACTION,    # On the bus, choosing what to do
	INTERACTING,     # Clicked on a character sprite
	IN_EVENT,        # Random event playing out
	IN_COMBAT,       # Combat encounter
	IN_CUTSCENE,     # Cutscene/dialogue scene
	TRAVELING,       # Moving between map nodes
	COIN_FLIP,       # Coin flip gamble
	SAVING,          # "Journal updated"
	GAME_OVER,       # Death or ending screen
}

# ── Signals ──────────────────────────────────────────────
# Other scripts connect to these to react to state changes
signal state_changed(old_state: State, new_state: State)
signal phase_changed(new_phase: String, new_day: int)
signal day_changed(new_day: int)
signal resource_changed(resource: String, new_value: int)
signal crew_changed()
signal game_over_triggered(ending_type: String)

# ── Current State ────────────────────────────────────────
var current_state: State = State.TITLE
var is_transitioning: bool = false

# ── Game Data (mirrors the SQLite game_state table) ──────
var player_name: String = ""
var current_day: int = 1
var current_phase: String = "morning"
var subj_pronoun: String = "they"
var obj_pronoun: String = "them"
var poss_pronoun: String = "their"


func _ready() -> void:
	print("[GameManager] Initialized")


# ── State Transitions ────────────────────────────────────

func transition_to(new_state: State) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	var old_state = current_state
	current_state = new_state
	
	print("[GameManager] %s -> %s" % [State.keys()[old_state], State.keys()[new_state]])
	state_changed.emit(old_state, new_state)
	
	is_transitioning = false


func get_state_name() -> String:
	return State.keys()[current_state]


# ── Phase Management ─────────────────────────────────────

var PHASES: Array[String] = ["morning", "afternoon", "evening", "midnight"]

func advance_phase() -> void:
	var idx = PHASES.find(current_phase)
	if idx < 3:
		current_phase = PHASES[idx + 1]
	else:
		current_phase = "morning"
		current_day += 1
		day_changed.emit(current_day)
	
	phase_changed.emit(current_phase, current_day)


func get_era() -> String:
	if current_day <= 7:
		return "breathing"
	elif current_day <= 14:
		return "squeeze"
	else:
		return "endgame"


# ── Save/Load ────────────────────────────────────────────

func can_save() -> bool:
	return current_state == State.PHASE_ACTION


func start_new_game(p_name: String, pronouns: Dictionary) -> void:
	player_name = p_name
	subj_pronoun = pronouns.get("subj", "they")
	obj_pronoun = pronouns.get("obj", "them")
	poss_pronoun = pronouns.get("poss", "their")
	current_day = 1
	current_phase = "morning"
	transition_to(State.INTRO)
