extends Node

class Player:
    var name: String
    var level: int
    var pClass: String
    var health: int
    var stamina: float
    var stats: Dictionary
	
    var strikes: Array 
    var skills: Array  #Attacks are given as lists of attack names
    var spells: Array  #Definitions and processing handled elsewhere
    var special: Array #Same for equipment
    var equipment: Array
    var resistances: Array
	

    func _init(setName, setLevel, setClass):
        name = setName
        level = setLevel
        pClass = setClass

        stamina = 100

        setStats()

    func setStats():
        stats = {
            vitality = calcStat("vitality"),
			defence = calcStat("defence"),
			strength = calcStat("strength"),
			agility = calcStat("agility"),
			will = calcStat("will"),
			spirit = calcStat("spirit"),
			endurance = calcStat("endurance"),
			luck = calcStat("luck"),
        }

        health = 10 * stats.vitality

    func calcStat(stat: String):
		
        var statDeterminer = Classes.classes[pClass][stat]
        return roundi((10 + statDeterminer) + pow(level/2.0, 2 + statDeterminer/20.0))

    func takeDamage(damage: int):
        health = max(0, health-damage)
