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
		{
			name = "Slime",
			level = 1,
			stats = {
				vitality = 20,
				defence = 10,
				strength = 10,
				agility = 30,
				will = 0,
				spirit = 10,
				endurance = 30,
				luck = 0,
			},
			skills = [],
			resistances = ["Slashing"],
		},
		{
			name = "Slime",
			level = 3,
			stats = {
				vitality = 24,
				defence = 12,
				strength = 12,
				agility = 12,
				will = 0,
				spirit = 12,
				endurance = 36,
				luck = 0,
			},
	    	skills = [],
			resistances = ["Slashing"],
		},
	]

    call_deferred("_go_to_battle_scene")



func _go_to_battle_scene():
    print("leaving menu")
    get_tree().change_scene_to_file("res://battle/battle_scene.tscn")