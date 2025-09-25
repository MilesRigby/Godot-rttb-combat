extends Node

class Slime:
    var name: String
    var level: int
    var health: int
    var stats: Dictionary
    var skills: Array
    var resistances: Array

    func _init(setLevel):
        name = "Slime"
        level = setLevel

        var stat_determiner = setLevel-1
        stats = {
            vitality = 20 + 2*stat_determiner,
			defence = 10 + stat_determiner,
			strength = 10 + stat_determiner,
			agility = 30 + 3*stat_determiner,
			will = 0,
			spirit = 10 + stat_determiner,
			endurance = 30 + 3*stat_determiner,
			luck = 0,
        }

        health = stats.vitality
        skills = ["Slash"]
        resistances = ["Slashing"]