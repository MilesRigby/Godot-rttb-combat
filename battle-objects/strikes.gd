extends Node

const objectsSource = preload("res://battle-data/combatants.gd")

func slash(user, target):
	var damage = user.stats.strength
	damage *= 0.9 + randf()/5
	damage = pow(damage, (1 + user.level/100.0))
	damage /= pow((1 + target.stats.defence/100.0), 2)
	if target.resistances.has("Slashing"):
		damage *= 0.5

func _ready():
	var objects = objectsSource.new()
	slash(objects.playerCharacters[0], objects.enemies[0])
	slash(objects.playerCharacters[0], objects.enemies[1])
	slash(objects.enemies[0], objects.playerCharacters[0])
	slash(objects.enemies[1], objects.playerCharacters[0])
