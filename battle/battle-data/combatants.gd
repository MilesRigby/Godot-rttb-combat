extends Node

#Vit - health, players get *10 bonus by default
#Def - reduces damage taken from physical attacks
#Str - increases damage and decreases wind-up time for physical abilities (strikes and skills)
#Agi - increases Def of those on back row and reduced cool-down time after physical abilities
#Wil - increases magic damage and reduces wind-up time on magical abilities (spells and special)
#Spr - reduces damage taken from magic attacks and reduces cool-down time on magical abilities
#End - decreases stamina costs and recovery time after interupts
#Lck - increases drops and drop-rates (does nothing)

var playerCharacters = []

var enemies = []

func DamagePlayer(player, damage):
    playerCharacters[player].health = max(0, playerCharacters[player].health - damage)

func DamageEnemy(enemy, damage):
    enemies[enemy].health = max(0, enemies[enemy].health - damage)