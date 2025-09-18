extends Node

var attacksDict = {
	"slash": [{
		damageType = "Slashing",
		baseDamage = 1,
		damageMin = 1,
		damageMax = 1},],
}

func CalculateDamage(user, attack, target):
	var totalDamage = 0

	for damageSource in attacksDict[attack]:
		var damage = 1

		if (target.resistances.has(damageSource.damageType)):
			damage -= 0.5

		damage *= damageSource.baseDamage

		damage *= randf_range(0, damageSource.damageMax-damageSource.damageMin) + (damageSource.damageMin+damageSource.damageMax)/2

		totalDamage += damage

	totalDamage *= pow(user.stats.strength, 1 + user.level/100.0)
	totalDamage /= pow((1 + target.stats.defence/100.0), 2)

	totalDamage = roundi(totalDamage)

	return totalDamage

		

func _ready():
	print(CalculateDamage(Combatants.playerCharacters[0], "slash", Combatants.enemies[0]))
	print(CalculateDamage(Combatants.playerCharacters[0], "slash", Combatants.enemies[1]))
	print(CalculateDamage(Combatants.enemies[0], "slash", Combatants.playerCharacters[0]))
	print(CalculateDamage(Combatants.enemies[1], "slash", Combatants.playerCharacters[0]))
