require_relative 'utils/parser'
require_relative 'utils/ranking'

def main
  file_name = "data/qgames.log"
  games = Parser.parse_log(file_name)

  # 3.3 - Create a script that prints a report (grouped information) for each match (...)
  # 3.4 - Generate a report of deaths grouped by death cause for each match.
  games.each do |game|
    puts "---------------------- MATCH #{game.name} REPORT ----------------------"
    game.match_report
  end

  # 3.3. - (...) and a player ranking.
  puts "---------------------------- GLOBAL RANKING ----------------------------"
  Ranking.global_ranking(games)
  puts "------------------------------------------------------------------------"

end


main
