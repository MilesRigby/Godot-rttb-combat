extends Node2D

func _ready():

    Combatants.playerCharacters = [
        {
            name = "Jeff", #Player character name
            row = "front", #Front or back row in combat
            level = 1,
            stats = {
                vitality = 10,
                defence = 10,
                strength = 10,
                agility = 10,
                will = 10,
                spirit = 10,
                endurance = 10,
                luck = 10,
            },
            strikes = [],
            skills = [], #Attacks are given as lists of attack names
            spells = [], #Definitions and processing handled elsewhere
            special = [],#Same for equipment
            equipment = [],
            resistances = [],
        },
    ]

    Combatants.enemies = [
		EnemyCombatant.Slime.new(1),
		EnemyCombatant.Slime.new(3),
	]

    call_deferred("_go_to_battle_scene")



func _go_to_battle_scene():
    get_tree().change_scene_to_file("res://battle/battle_scene.tscn")