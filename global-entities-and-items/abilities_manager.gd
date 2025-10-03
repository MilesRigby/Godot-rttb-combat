extends Node

var attacksDict = {
	"Slash": {
		type = "Physical",
		baseWindUp = 2,
		baseCoolDown = 2,
		baseStaminaCost = 10,
		components = [{
			damageType = "Slashing",
			baseDamage = 1,
			damageMin = 0.9,
			damageMax = 1.1},],
	},
	"Edge Drive": {
		type = "Physical",
		baseWindUp = 6,
		baseCoolDown = 4,
		baseStaminaCost = 80,
		components = [{
			damageType = "Impact",
			baseDamage = 3,
			damageMin = 0.5,
			damageMax = 1.5},],
	},
}

# Will need to be updated to work with more complex resistances interactions and different attack types
# Also eventually weapon damage and take status effects into account
func CalculateDamage(user, attack, target):
	var totalDamage = 0 # Running total of all damage dealt

	for damageSource in attacksDict[attack].components:
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
