extends Node
## AudioManager — Handles background music with crossfading and one-shot SFX.
## Autoload singleton — access as AudioManager from anywhere.

# ── Music Players (two for crossfading) ──────────────────
var music_player_a: AudioStreamPlayer
var music_player_b: AudioStreamPlayer
var active_player: AudioStreamPlayer
var inactive_player: AudioStreamPlayer

# ── SFX Player ───────────────────────────────────────────
var sfx_player: AudioStreamPlayer

# ── State ────────────────────────────────────────────────
var current_track: String = ""
var is_crossfading: bool = false
var music_volume_db: float = -5.0
var sfx_volume_db: float = 0.0

# ── Phase Music Mapping ──────────────────────────────────
var phase_music: Dictionary = {
	"title": "res://assets/audio/music/title.ogg",
	"intro": "res://assets/audio/music/intro.ogg",
	"morning": "res://assets/audio/music/morning.ogg",
	"morning_late": "res://assets/audio/music/day_10_morning.ogg",
	"afternoon": "res://assets/audio/music/afternoon.ogg",
	"evening": "res://assets/audio/music/evening.ogg",
	"midnight": "res://assets/audio/music/midnight.mp3",
	"combat": "res://assets/audio/music/combat.ogg",
	"event": "res://assets/audio/music/event.ogg",
	"horror_ambient": "res://assets/audio/music/horror_ambient.mp3",
	"haven": "res://assets/audio/music/haven.ogg",
	"gameover": "res://assets/audio/music/gameover.mp3",
	"travel": "res://assets/audio/music/travel.ogg",
}

var sfx_map: Dictionary = {
	"click": "res://assets/audio/sfx/click.ogg",
	"confirm": "res://assets/audio/sfx/confirm.ogg",
	"back": "res://assets/audio/sfx/back.ogg",
	"gunshot": "res://assets/audio/sfx/gunshot.ogg",
	"bite": "res://assets/audio/sfx/bite.ogg",
	"loot": "res://assets/audio/sfx/loot.ogg",
	"upgrade": "res://assets/audio/sfx/upgrade.ogg",
	"engine_start": "res://assets/audio/sfx/engine_start.ogg",
}


func _ready() -> void:
	# Create the audio players as children
	music_player_a = AudioStreamPlayer.new()
	music_player_a.bus = "Music"
	music_player_a.volume_db = music_volume_db
	add_child(music_player_a)
	
	music_player_b = AudioStreamPlayer.new()
	music_player_b.bus = "Music"
	music_player_b.volume_db = -80.0  # Start silent
	add_child(music_player_b)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	sfx_player.volume_db = sfx_volume_db
	add_child(sfx_player)
	
	active_player = music_player_a
	inactive_player = music_player_b
	
	print("[AudioManager] Initialized")


# ── Music ────────────────────────────────────────────────

func play_music(track_name: String, crossfade_time: float = 1.5) -> void:
	if track_name == current_track and active_player.playing:
		return  # Already playing this track
	
	var path = phase_music.get(track_name, "")
	if path == "" or not ResourceLoader.exists(path):
		# No audio file found — silent fail (game works without audio)
		return
	
	current_track = track_name
	var stream = load(path) as AudioStream
	if stream == null:
		return
	
	# Crossfade: fade out active, fade in inactive
	inactive_player.stream = stream
	inactive_player.volume_db = -80.0
	inactive_player.play()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(active_player, "volume_db", -80.0, crossfade_time)
	tween.tween_property(inactive_player, "volume_db", music_volume_db, crossfade_time)
	
	await tween.finished
	active_player.stop()
	
	# Swap active/inactive
	var temp = active_player
	active_player = inactive_player
	inactive_player = temp


func stop_music(fade_time: float = 1.0) -> void:
	current_track = ""
	var tween = create_tween()
	tween.tween_property(active_player, "volume_db", -80.0, fade_time)
	await tween.finished
	active_player.stop()


func play_phase_music(phase: String, day: int = 1) -> void:
	if phase == "morning" and day >= 10:
		play_music("morning_late")
	else:
		play_music(phase)


# ── SFX ──────────────────────────────────────────────────

func play_sfx(sfx_name: String) -> void:
	var path = sfx_map.get(sfx_name, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	
	var stream = load(path) as AudioStream
	if stream:
		sfx_player.stream = stream
		sfx_player.play()


# ── Navigation Sounds ────────────────────────────────────

func play_click() -> void:
	play_sfx("click")

func play_confirm() -> void:
	play_sfx("confirm")

func play_back() -> void:
	play_sfx("back")
