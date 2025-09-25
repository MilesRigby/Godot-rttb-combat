# TODO: figure out input (ui_down not being registered) and test current state of program

extends Node2D

# Time in seconds of each battle step, used for processing attack wind-ups and cooldowns
var timestep = 0.02

var playerAttacks = [] # Attack being used by each player character/enemy
var enemyAttacks = []
var enemyNextAttacks = [] # Enemy attacks decided ahead of time, can be used to show the player what the enemy will do next

var playerTargets = [] # Opponent being targeted by each player character/enemy
var enemyTargets = []

var playerWindUps = [] # Wind up and cooldown times for each attack set by each player character/enemy
var playerCooldowns = []
var enemyWindUps = []
var enemyCooldowns = []

# The active player and whether they are in an active menu
var playerNum
var playerTurnActive = false

# Tracks when the player wins/loses
var battleEnd = false

# Sets up player and enemy actions and cooldowns for use during the battle
# Each array contains one entry per combatant of that type
func _ready():

	for playerCharacter in Combatants.playerCharacters:
		playerAttacks.append("") # Empty string - no attack

		playerTargets.append(0) # Negative value - no target

		playerWindUps.append(0) # 0 for no upcoming attack
		playerCooldowns.append(timestep) # timestep delay ensuring player acts immediately on battle start

	for enemy in Combatants.enemies:
		enemyAttacks.append("")
		enemyNextAttacks.append(enemy.skills[randi() % enemy.skills.size()])

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

	print("\n\n\n\n\n\n\n\n\n\n\n\n") # 'Clears' console
	var consoleInfo = "Enemies: \nHealth: \nAttack: \nTarget:  \nWind up: \nCooldown: \nNext: \nPlayers: \nHealth: \nAttack: \nTraget: \nWind up: \nCooldown:".split("\n")
	for i in range(0, Combatants.enemies.size()):
		consoleInfo[0] = consoleInfo[0] + "(" + str(i) + ") " + Combatants.enemies[i].name + " "
		consoleInfo[1] = consoleInfo[1] + "    " + str(Combatants.enemies[i].health) + " "
		consoleInfo[2] = consoleInfo[2] + "    " + enemyAttacks[i] + " "
		consoleInfo[3] = consoleInfo[3] + "    " + Combatants.playerCharacters[enemyTargets[i]].name + " "
		consoleInfo[4] = consoleInfo[4] + "    " + str(enemyWindUps[i]) + " "
		consoleInfo[5] = consoleInfo[5] + "  " + str(enemyCooldowns[i]) + "   "
		consoleInfo[6] = consoleInfo[6] + "    " + enemyNextAttacks[i] + " "

	for i in range(0, Combatants.playerCharacters.size()):
		consoleInfo[7] = consoleInfo[7] + "(" + str(i) + ") " + Combatants.playerCharacters[i].name + " "
		consoleInfo[8] = consoleInfo[8] + "    " + str(Combatants.playerCharacters[i].health) + " "
		consoleInfo[9] = consoleInfo[9] + "    " + playerAttacks[i] + " "
		consoleInfo[10] = consoleInfo[10] + "    " + str(playerTargets[i]) + " "
		consoleInfo[11] = consoleInfo[11] + "    " + str(playerWindUps[i]) + " "
		consoleInfo[12] = consoleInfo[12] + "  " + str(playerCooldowns[i]) + "   "

	

	consoleInfo = "\n".join(consoleInfo)
	print(consoleInfo)

	var noneRemaining = true

	for i in range(0, Combatants.playerCharacters.size()):
		if Combatants.playerCharacters[i].health > 0:
			noneRemaining = false
			while playerTurnActive:
				await get_tree().create_timer(timestep).timeout
			playerNum = i
			ProcessPlayer()

	if noneRemaining:
		print("You Lose!")
		battleEnd = true


	noneRemaining = true

	for i in range(0, Combatants.enemies.size()):
		if Combatants.enemies[i].health > 0:
			noneRemaining = false
			ProcessEnemy(i)

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
		print(attackName + "; ")

func _input(_e):
	if playerTurnActive && Input.is_action_just_pressed("ui_down"):
		SetPlayerAttack(Combatants.playerCharacters[playerNum].strikes[0])
		playerTurnActive = false

func SetPlayerAttack(attack):
	playerAttacks[playerNum] = attack
	playerTargets[playerNum] = 0

	var windUp = GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[attack].baseWindUp / sqrt(1 + Combatants.playerCharacters[playerNum].stats.strength), timestep)
	var cooldown = GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[attack].baseCoolDown / sqrt(1 + Combatants.playerCharacters[playerNum].stats.agility), timestep)

	# Ensure minimum time is 1 second, extending whichever part of the attack period is already longer
	if windUp+cooldown < 1:
		if (windUp < cooldown):
			cooldown = 1 - windUp
		else:
			windUp = 1 - cooldown

	playerWindUps[playerNum] = windUp
	playerCooldowns[playerNum] = cooldown

# Determine whether the enemy is attacking or choosing their next attack
func ProcessEnemy(enemyNum):

	if enemyWindUps[enemyNum] >= timestep-0.0001:
		enemyWindUps[enemyNum] -= timestep

		if enemyWindUps[enemyNum] <= 0:
			EnemyAttack(enemyNum)

	elif enemyCooldowns[enemyNum] >= timestep-0.0001:
		enemyCooldowns[enemyNum] -= timestep

		if enemyCooldowns[enemyNum] <= 0:
			SetEnemyAttack(enemyNum)

# Evaluate the effect of the player attacking the enemy
func EnemyAttack(enemyNum):

	var attacker = Combatants.enemies[enemyNum]
	var attack = enemyAttacks[enemyNum]
	var target = Combatants.playerCharacters[enemyTargets[enemyNum]]

	var damage = AbilitiesManager.CalculateDamage(attacker, attack, target)

	Combatants.DamagePlayer(enemyTargets[enemyNum], damage)

func SetEnemyAttack(enemyNum):
	var nextAttack = Combatants.enemies[enemyNum].skills[randi() % Combatants.enemies[enemyNum].skills.size()]
	enemyAttacks[enemyNum] = enemyNextAttacks[enemyNum]
	enemyNextAttacks[enemyNum] = nextAttack
	enemyTargets[enemyNum] = randi() % Combatants.playerCharacters.size()

	var windUp = GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[enemyAttacks[enemyNum]].baseWindUp / sqrt(1 + Combatants.enemies[enemyNum].stats.strength), timestep)
	var cooldown = GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[enemyAttacks[enemyNum]].baseCoolDown / sqrt(1 + Combatants.enemies[enemyNum].stats.agility), timestep)

	# Ensure minimum time is 1 second, extending whichever part of the attack period is already longer
	if windUp+cooldown < 1:
		if (windUp < cooldown):
			cooldown = 1 - windUp
		else:
			windUp = 1 - cooldown

	enemyWindUps[enemyNum] = windUp
	enemyCooldowns[enemyNum] = cooldown
