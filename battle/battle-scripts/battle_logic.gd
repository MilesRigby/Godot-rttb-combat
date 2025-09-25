# TODO: figure out input (ui_down not being registered) and test current state of program

extends Node2D

var timestep = 0.02

var playerAttacks = [] # Attack being used by each player character/enemy
var enemyAttacks = []

var playerTargets = [] # Opponent being targeted by each player character/enemy
var enemyTargets = []

var playerWindUps = [] # Wind up and cooldown times for each attack set by each player character/enemy
var playerCooldowns = []
var enemyWindUps = []
var enemyCooldowns = []

var playerNum
var playerTurnActive = false

var battleEnd = false

func _ready():

	for playerCharacter in Combatants.playerCharacters:
		playerAttacks.append("") # Empty string - no attack

		playerTargets.append(0) # Negative value - no target

		playerWindUps.append(0) # 0 for no upcoming attack
		playerCooldowns.append(5*timestep) # timestep delay ensuring player acts immediately on battle start

	for enemy in Combatants.enemies:
		enemyAttacks.append("")

		enemyTargets.append(-1)

		enemyWindUps.append(0)
		enemyCooldowns.append(timestep)

	BattleProcess()

func BattleProcess():
	while !battleEnd:
		if !playerTurnActive:
			BattleStep()
		await get_tree().create_timer(timestep).timeout

# One timestep (0.02 seconds) of the battle.
func BattleStep():

	print("Enemy health: " + str(Combatants.enemies[0].health) + "; wind up: " + str(playerWindUps[0]) + "; cooldown: " + str(playerCooldowns[0]))

	var noneRemaining = true

	for i in range(0, Combatants.playerCharacters.size()):
		if Combatants.playerCharacters[i].health > 0:
			noneRemaining = false
			playerNum = i
			ProcessPlayer()

	if noneRemaining:
		print("You Lose!")
		battleEnd = true


	noneRemaining = true

	for i in range(0, Combatants.enemies.size()):
		if Combatants.enemies[i].health > 0:
			noneRemaining = false
		#    ProcessEnemy(i)

	if noneRemaining:
		print("You Win!")
		battleEnd = true


# Determine whether the player is attacking or choosing their next attack
func ProcessPlayer():

	if playerWindUps[playerNum] >= timestep-0.0001:
		playerWindUps[playerNum] -= timestep

		if playerWindUps[playerNum] <= 0:
			PlayerAttack()

	elif playerCooldowns[playerNum] >= timestep-0.0001:
		playerCooldowns[playerNum] -= timestep

		if playerCooldowns[playerNum] <= 0:
			StartPlayerTurn()

# Evaluate the effect of the player attacking the enemy
func PlayerAttack():

	var attacker = Combatants.playerCharacters[playerNum]
	var attack = playerAttacks[playerNum]
	var target = Combatants.enemies[playerTargets[playerNum]]

	var damage = AbilitiesManager.CalculateDamage(attacker, attack, target)

	Combatants.DamageEnemy(playerTargets[playerNum], damage)

func StartPlayerTurn():
	playerTurnActive = true

	print("Available actions:")
	for attackName in Combatants.playerCharacters[playerNum].strikes:
		print(attackName)

func _input(_e):
	if playerTurnActive && Input.is_action_just_pressed("ui_down"):
		SetPlayerAttack(Combatants.playerCharacters[playerNum].strikes[0])
		playerTurnActive = false

func SetPlayerAttack(attack):
	playerAttacks[playerNum] = attack
	playerTargets[playerNum] = 0
	var windUp = GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[attack].baseWindUp / sqrt(1 + Combatants.playerCharacters[playerNum].stats.strength), timestep)
	var coolDown = GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[attack].baseCoolDown / sqrt(1 + Combatants.playerCharacters[playerNum].stats.agility), timestep)

	# Ensure minimum time is 1 second, extending whichever part of the attack period is already longer
	if windUp+coolDown < 1:
		if (windUp < coolDown):
			coolDown = 1 - windUp
		else:
			windUp = 1 - coolDown

	playerWindUps[playerNum] = windUp
	playerCooldowns[playerNum] = coolDown
