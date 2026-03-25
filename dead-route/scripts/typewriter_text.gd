extends RichTextLabel
## TypewriterText — Reveals text character by character with optional beep sounds.
## Attach this script to any RichTextLabel to give it typewriter behavior.
##
## Usage:
##   $NarrativeText.show_text("The bus rumbles forward...")
##   await $NarrativeText.text_finished

class_name TypewriterText

# ── Signals ──────────────────────────────────────────────
signal text_finished
signal text_skipped

# ── Configuration ────────────────────────────────────────
@export var characters_per_second: float = 35.0
@export var punctuation_pause_mult: float = 4.0  ## Extra delay on . ! ?
@export var comma_pause_mult: float = 2.0        ## Extra delay on ,
@export var enable_beep: bool = false
@export var beep_pitch: float = 1.0              ## Per-character voice pitch

# ── State ────────────────────────────────────────────────
var is_typing: bool = false
var can_skip: bool = true
var _full_text: String = ""
var _tween: Tween = null


func _ready() -> void:
	# Start with no visible characters
	visible_characters = 0
	bbcode_enabled = true


func show_text(new_text: String, speed_override: float = -1.0) -> void:
	"""Display text with typewriter effect. Await text_finished for completion."""
	# Stop any existing typewriter
	_stop_tween()
	
	_full_text = new_text
	text = new_text
	visible_characters = 0
	is_typing = true
	
	var speed = speed_override if speed_override > 0 else characters_per_second
	var total_chars = _full_text.length()
	
	if total_chars == 0:
		is_typing = false
		text_finished.emit()
		return
	
	# Calculate total duration accounting for punctuation pauses
	var total_time = float(total_chars) / speed
	
	# Use a tween to increment visible_characters
	_tween = create_tween()
	_tween.tween_property(self, "visible_characters", total_chars, total_time)
	_tween.finished.connect(_on_tween_finished)


func show_text_instant(new_text: String) -> void:
	"""Display text immediately with no animation."""
	_stop_tween()
	_full_text = new_text
	text = new_text
	visible_characters = -1  # Show all
	is_typing = false


func skip() -> void:
	"""Skip to end of current text immediately."""
	if is_typing and can_skip:
		_stop_tween()
		visible_characters = -1  # Show all characters
		is_typing = false
		text_skipped.emit()
		text_finished.emit()


func clear_text() -> void:
	"""Clear all text."""
	_stop_tween()
	text = ""
	_full_text = ""
	visible_characters = 0
	is_typing = false


func append_text_typewriter(new_text: String) -> void:
	"""Append text to existing content with typewriter effect."""
	var existing = _full_text
	show_text(existing + new_text)
	# Skip ahead to where old text ended
	visible_characters = existing.length()


# ── Input ────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if is_typing and can_skip:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
			skip()
			get_viewport().set_input_as_handled()


# ── Internal ─────────────────────────────────────────────

func _stop_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null


func _on_tween_finished() -> void:
	is_typing = false
	text_finished.emit()
