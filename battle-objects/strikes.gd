extends Node

func slash(user, target):
	var damage = user.stats.strength
	damage *= 0.9 + randf()/5
	damage = pow(damage, (1 + user.level/100.0))
	damage /= pow((1 + target.stats.defence/100.0), 2)
	if target.resistances.has("Slashing"):
		damage *= 0.5
	print(damage)

func _ready():
	slash(Combatants.playerCharacters[0], Combatants.enemies[0])
	slash(Combatants.playerCharacters[0], Combatants.enemies[1])
	slash(Combatants.enemies[0], Combatants.playerCharacters[0])
	slash(Combatants.enemies[1], Combatants.playerCharacters[0])
