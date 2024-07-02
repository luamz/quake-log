# Quake Log Parsers

This project consists of a log parser for the game Quake III Arena, which analyzes and generates reports based on the logs.

### Requirements
- Ruby 3.0
- Minitest
- Rake
  
## Running

To run the project, execute the following command:
``ruby main.rb``

To run the tests, execute:
`` rake test``

## Reports
The project supports the following reports:
1 - Match info report for each match on the file
2 - A player ranking
3 - Death by cause report for each match

You can comment the ones you don't need.

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
  }
}
```

### Ranking
```
1. Isgalamido - Kills: 100
2. Dono da Bola - Kills: 90
3. Assasinu Credi - Kills: 80
```

#### Death by Cause Report
```json
"game_1": {
  "kills_by_means": {
    "MOD_SHOTGUN": 10,
    "MOD_RAILGUN": 2,
    "MOD_GAUNTLET": 1,
  }
}
```
