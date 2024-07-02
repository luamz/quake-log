# Quake Log Parsers

This project consists of a log parser for the game Quake III Arena, which analyzes and generates reports based on the logs.

## Requirements
- Ruby 3.0

#### Built-In Gems
- Minitest
- Rake

## Running
To run the project, execute the following command:
``ruby main.rb``

To run the tests, execute:
``rake test``
  
## Structure

``data/qgames.log`` is an example log file

``models/`` - classes used by the project

``utils/`` - utility modules used to parse and rank the log

``tests/`` - tests developed for the project

## Reports
The project supports the following reports:

1 - Match info report for each match on the file

2 -  A player ranking



### Examples

#### Match Report
```json
"game_1": {
"total_kills": 45,
"players": ["Dono da bola", "Isgalamido", "Zeh"],
"kills": {
  "Dono da bola": 5,
  "Isgalamido": 18,
  "Zeh": 20
  },
"kills_by_means": {
  "MOD_SHOTGUN": 20,
  "MOD_RAILGUN": 21,
  "MOD_GAUNTLET": 4,
  }
}
```

#### Ranking
```
1. Isgalamido (id:2) - Kills: 100
2. Dono da Bola (id:1) - Kills: 90
3. Assasinu Credi (id:3) - Kills: 80
```

