extends Node
## Balance — All tunable game numbers live here.
## Autoload singleton — access as Balance from anywhere.

# ── Starting Resources ───────────────────────────────────
var STARTING_RESOURCES: Dictionary = {
	"fuel": 20,
	"food": 8,
	"scrap": 4,
	"ammo": 5,
	"medicine": 1,
}

# ── Combat Encounter Rates (by era and phase) ────────────
var COMBAT_CHANCE: Dictionary = {
	"breathing": {"morning": 0.15, "afternoon": 0.25, "evening": 0.40, "midnight": 0.65},
	"squeeze":   {"morning": 0.25, "afternoon": 0.40, "evening": 0.60, "midnight": 0.80},
	"endgame":   {"morning": 0.35, "afternoon": 0.50, "evening": 0.70, "midnight": 0.90},
}

# ── Scavenging Yields ────────────────────────────────────
var SCAVENGE_MULTIPLIER: Dictionary = {
	"breathing": 1.5,
	"squeeze":   1.0,
	"endgame":   0.65,
}

# ── Scar Chance ──────────────────────────────────────────
var SCAR_CHANCE: Dictionary = {
	"breathing": {"pyrrhic": 0.0,  "defeat": 0.0},
	"squeeze":   {"pyrrhic": 0.12, "defeat": 0.25},
	"endgame":   {"pyrrhic": 0.18, "defeat": 0.35},
}

# ── Infection Chance ─────────────────────────────────────
var INFECTION_CHANCE: Dictionary = {
	"breathing": {"pyrrhic": 0.0,  "defeat": 0.0},
	"squeeze":   {"pyrrhic": 0.10, "defeat": 0.20},
	"endgame":   {"pyrrhic": 0.15, "defeat": 0.30},
}

# ── Rest Healing ─────────────────────────────────────────
var REST_HEALING: Dictionary = {
	"breathing": {"morning": 12, "afternoon": 16, "evening": 22, "midnight": 28},
	"squeeze":   {"morning": 8,  "afternoon": 12, "evening": 18, "midnight": 22},
	"endgame":   {"morning": 6,  "afternoon": 10, "evening": 14, "midnight": 18},
}

# ── Medicine Healing ─────────────────────────────────────
var MEDICINE_BASE_HEAL: int = 50
var MEDICINE_PHASE_BONUS: Dictionary = {
	"morning": 0, "afternoon": 5, "evening": 10, "midnight": 15,
}

# ── Fuel Leak Per Day ────────────────────────────────────
var FUEL_LEAK: Dictionary = {
	"breathing": 1,
	"squeeze":   2,
	"endgame":   2,
}

# ── Event Frequency ──────────────────────────────────────
var EVENT_CHANCE: Dictionary = {
	"breathing": 0.20,
	"squeeze":   0.25,
	"endgame":   0.30,
}

# ── Explore Guarantee (Days 1-7 always find something) ───
var EXPLORE_GUARANTEED_LOOT_ERAS: Array[String] = ["breathing"]


# ── Utility ──────────────────────────────────────────────

func get_value(table_name: String, era: String = "") -> Variant:
	if era == "":
		era = GameManager.get_era()
	
	var table = get(table_name)
	if table is Dictionary and table.has(era):
		return table[era]
	return null


func _ready() -> void:
	print("[Balance] Initialized")
