extends Node2D

func _ready():

    Combatants.playerCharacters = [
        PlayerObjects.Player.new("John", 10, "Warrior")
    ]

    Combatants.playerCharacters[0].strikes = ["Slash", "Edge Drive"]

    Combatants.enemies = [
		EnemyCombatant.Slime.new(10),
        EnemyCombatant.Slime.new(10),
	]

    call_deferred("_go_to_battle_scene")



func _go_to_battle_scene():
    get_tree().change_scene_to_file("res://battle/battle_scene.tscn")