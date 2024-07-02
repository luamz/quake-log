require_relative 'utils/parser'
require_relative 'utils/ranking'

def main
  file_name = "qgames.log"
  games = Parser.parse_log(file_name)

  # 3.3 - Create a script that prints a report (grouped information) for each match and a player ranking.
  games.each do |game|
    puts "---------------------- MATCH #{game.name} REPORT ----------------------"
    game.match_report
  end
  puts "---------------------------- GLOBAL RANKING ----------------------------"
  Ranking.global_ranking(games)

  # 3.4 - Generate a report of deaths grouped by death cause for each match.
  games.each do |game|
    puts "------------- DEATH BY CAUSE REPORT (MATCH #{game.name}) -------------"
    game.death_report
  end
end


main
