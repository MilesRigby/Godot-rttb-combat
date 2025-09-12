extends Node

#Vit - health, players get *10 bonus by default
#Def - reduces damage taken from physical attacks
#Str - increases damage and decreases wind-up time for physical abilities (strikes and skills)
#Agi - increases Def of those on back row and reduced cool-down time after physical abilities
#Wil - increases magic damage and reduces wind-up time on magical abilities (spells and special)
#Spr - reduces damage taken from magic attacks and reduces cool-down time on magical abilities
#End - decreases stamina costs and recovery time after interupts
#Lck - increases drops and drop-rates (does nothing)

var playerCharacters = [
    {
        name = "Jeff", #Player character name
        row = "front", #Front or back row in combat
        level = 1,
        stats = {
            vitality = 10,
            defence = 10,
            strength = 10,
            agility = 10,
            will = 10,
            spirit = 10,
            endurance = 10,
            luck = 10,
        },
        strikes = [],
        skills = [], #Attacks are given as lists of attack names
        spells = [], #Definitions and processing handled elsewhere
        special = [],#Same for equipment
        equipment = [],
        resistances = [],
    },
]

var enemies = [
    {
        name = "Slime",
        level = 1,
        stats = {
            vitality = 20,
            defence = 10,
            strength = 10,
            agility = 30,
            will = 0,
            spirit = 10,
            endurance = 30,
            luck = 0,
        },
        skills = [],
        resistances = ["Slashing"],
    },
    {
        name = "Slime",
        level = 3,
        stats = {
            vitality = 24,
            defence = 12,
            strength = 12,
            agility = 12,
            will = 0,
            spirit = 12,
            endurance = 36,
            luck = 0,
        },
        skills = [],
        resistances = ["Slashing"],
    },
]