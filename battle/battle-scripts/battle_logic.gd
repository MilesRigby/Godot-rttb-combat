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
var playerTurnPhase

# Currently selected attack/enemy for player
var attackOption
var targetOption

var playerTurns = []
var enemyTurns = []

# Tracks when the player wins/loses
var battleEnd = false

# Sets up player and enemy actions and cooldowns for use during the battle
# Each array contains one entry per combatant of that type
func _ready():

	Engine.physics_ticks_per_second = roundi(1/timestep)

	for playerCharacter in Combatants.playerCharacters:
		playerAttacks.append("") # Empty string - no attack

		playerTargets.append(0) # Negative value - no target

		playerWindUps.append(0) # 0 for no upcoming attack
		playerCooldowns.append(timestep*5) # timestep delay ensuring player acts immediately on battle start

	for enemy in Combatants.enemies:
		enemyAttacks.append("")
		enemyNextAttacks.append(enemy.skills[randi() % enemy.skills.size()])

		enemyTargets.append(-1)

		enemyWindUps.append(0)
		enemyCooldowns.append(timestep*2)



func _physics_process(_delta):

	if playerTurns.size() + enemyTurns.size() == 0:

		printInfo()

		for i in range(0, Combatants.playerCharacters.size()):
			if Combatants.playerCharacters[i].health > 0:
				ProcessPlayer(i)

		for i in range(0, Combatants.enemies.size()):
			if Combatants.enemies[i].health > 0:
				ProcessEnemy(i)

	# Add processing of player and enemy turns when a player turn is not already active


func ProcessPlayer(i):
	if playerWindUps[i] > 0:
		playerWindUps[i] = GlobalUtilities.arbitrary_round(playerWindUps[i] - timestep, timestep)
		
		if playerWindUps[i] == 0:
			PlayerAttack(i)


	elif playerCooldowns[i] > 0:
		playerCooldowns[i] = GlobalUtilities.arbitrary_round(playerCooldowns[i] - timestep, timestep)
		
		if playerCooldowns[i] == 0:
			playerTurns.append(i)

# Evaluate the effect of the player attacking the enemy
func PlayerAttack(i):

	var attacker = Combatants.playerCharacters[i]
	var attack = playerAttacks[i]
	var target = Combatants.enemies[playerTargets[i]]

	var damage = AbilitiesManager.CalculateDamage(attacker, attack, target)

	Combatants.DamageEnemy(playerTargets[i], damage)

	if !AllEnemiesDefeated():
		playerTurnActive = false
	else:
		print("You win!")

func StartPlayerTurn():
	playerTurnActive = true
	playerTurnPhase = "Ability"

	attackOption = 0
	targetOption = 0

	print("Available actions:")
	for attackName in Combatants.playerCharacters[playerNum].strikes:
		print(attackName + "; ")

func _input(_e):
	if playerTurnActive:
		match playerTurnPhase:
			"Ability":
				if Input.is_action_just_pressed("ui_accept") and AbilitiesManager.attacksDict[Combatants.playerCharacters[playerNum].strikes[attackOption]].baseStaminaCost/sqrt(Combatants.playerCharacters[playerNum].stats.agility) < Combatants.playerCharacters[playerNum].stamina:
					playerTurnPhase = "Target"
					print("Selected target: (" + str(targetOption) + ")")
				elif Input.is_action_just_pressed("ui_down"):
					if attackOption + 1 < Combatants.playerCharacters[playerNum].strikes.size():
						attackOption += 1
					print("Selected action: " + str(Combatants.playerCharacters[playerNum].strikes[attackOption]) + "; Cost: " + str(GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[Combatants.playerCharacters[playerNum].strikes[attackOption]].baseStaminaCost/sqrt(Combatants.playerCharacters[playerNum].stats.agility), 0.1)))
				elif Input.is_action_just_pressed("ui_up"):
					if attackOption - 1 >= 0:
						attackOption -= 1
					print("Selected action: " + str(Combatants.playerCharacters[playerNum].strikes[attackOption]) + "; Cost: " + str(GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[Combatants.playerCharacters[playerNum].strikes[attackOption]].baseStaminaCost/sqrt(Combatants.playerCharacters[playerNum].stats.agility), 0.1)))
			"Target":
				if Input.is_action_just_pressed("ui_text_backspace"):
					playerTurnPhase = "Ability"
					print("Selected action: " + str(Combatants.playerCharacters[playerNum].strikes[attackOption]) + "; Cost: " + str(GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[Combatants.playerCharacters[playerNum].strikes[attackOption]].baseStaminaCost/sqrt(Combatants.playerCharacters[playerNum].stats.agility), 0.1)))
				elif Input.is_action_just_pressed("ui_accept") and Combatants.enemies[targetOption].health > 0:
					SetPlayerAttack(Combatants.playerCharacters[playerNum].strikes[attackOption], targetOption)
					Combatants.playerCharacters[playerNum].stamina = GlobalUtilities.arbitrary_round(Combatants.playerCharacters[playerNum].stamina - GlobalUtilities.arbitrary_round(AbilitiesManager.attacksDict[Combatants.playerCharacters[playerNum].strikes[attackOption]].baseStaminaCost/sqrt(Combatants.playerCharacters[playerNum].stats.agility), 0.1), 0.1)
					playerTurnActive = false
				elif Input.is_action_just_pressed("ui_down"):
					if targetOption + 1 < Combatants.enemies.size():
						targetOption += 1
					print("Selected target: (" + str(targetOption) + ")")
				elif Input.is_action_just_pressed("ui_up"):
					if targetOption - 1 >= 0: 
						targetOption -= 1
					print("Selected target: (" + str(targetOption) + ")")


func SetPlayerAttack(attack, target):
	playerAttacks[playerNum] = attack
	playerTargets[playerNum] = target

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
func ProcessEnemy(i):

	if enemyWindUps[i] > 0:
		enemyWindUps[i] = GlobalUtilities.arbitrary_round(enemyWindUps[i] - timestep, timestep)
		
		if playerWindUps[i] == 0:
			EnemyAttack(i)


	elif enemyCooldowns[i] > 0:
		enemyCooldowns[i] = GlobalUtilities.arbitrary_round(enemyCooldowns[i] - timestep, timestep)
		
		if enemyCooldowns[i] == 0:
			enemyTurns.append(i)

# Evaluate the effect of the player attacking the enemy
func EnemyAttack(enemyNum):

	var attacker = Combatants.enemies[enemyNum]
	var attack = enemyAttacks[enemyNum]
	var target = Combatants.playerCharacters[enemyTargets[enemyNum]]

	var damage = AbilitiesManager.CalculateDamage(attacker, attack, target)

	Combatants.DamagePlayer(enemyTargets[enemyNum], damage)

	if !AllPlayersDefeated():
		playerTurnActive = false
	else:
		print("You lose!")

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

func printInfo():
	print("\n\n") # 'Clears' console
	var consoleInfo = "Enemies: \nHealth: \nAttack: \nTarget: \nWind up: \nCooldown: \nNext: \nPlayers: \nHealth: \nStamina: \nAttack: \nTraget: \nWind up: \nCooldown:".split("\n")
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
		consoleInfo[9] = consoleInfo[9] + "    " + str(Combatants.playerCharacters[i].stamina) + " "
		consoleInfo[10] = consoleInfo[10] + "    " + playerAttacks[i] + " "
		consoleInfo[11] = consoleInfo[11] + "    " + str(playerTargets[i]) + " "
		consoleInfo[12] = consoleInfo[12] + "    " + str(playerWindUps[i]) + " "
		consoleInfo[13] = consoleInfo[13] + "  " + str(playerCooldowns[i]) + "   "

	consoleInfo = "\n".join(consoleInfo)
	print(consoleInfo)

func AllEnemiesDefeated() -> bool:

	for i in range(0, Combatants.enemies.size()):
		if Combatants.enemies[i].health != 0:
			return false

	return true

func AllPlayersDefeated() -> bool:

	for i in range(0, Combatants.playerCharacters.size()):
		if Combatants.playerCharacters[i].health != 0:
			return false

	return true