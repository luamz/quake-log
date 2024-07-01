require_relative 'game'
require_relative 'utils'

def parse_game(file, game_id)
  game = Game.new(game_id)

  file.each_line do |line|

    # Skip to the next match on the file if the current game is over
    if line.include?("InitGame")
      file.pos = file.pos - line.bytesize - 1 # Rewinds file by one line
      break

    # Collect Clients
    elsif (player_changed = line.match(/^*ClientUserinfoChanged: (\d) n\\(.+?)\\.*/))
      id, name = player_changed.captures
      game.update_player(id, name)

    # Collect Kill Data
    elsif (kill = line.match(/^*Kill: (\d+) (\d+) \d+: .+ killed .+ by (.+)/))
      killer, killed, cause = kill.captures
      game.add_kill(killer, killed, cause)
    end
  end

  game
end

def parse_log(filename)
  games = []
  game_count = 0

  File.open(filename, "r") do |file|
    file.each_line do |line|

      # Group information for each game in the file
      if line.include?("InitGame")
        game_count += 1
        current_game = parse_game(file, game_count)
        games << current_game
      end

    end
  end

  games
end

def main
  filename = "qgames.log"
  games = parse_log(filename)

  # 3.3 - Create a script that prints a report (grouped information) for each match and a player ranking.
  games.each do |game|
    puts "------------- MATCH #{game.name} REPORT -------------"
    game.match_report
  end
  puts "------------- GLOBAL RANKING -------------"
  global_ranking(games)

  # 3.4 - Generate a report of deaths grouped by death cause for each match.
  games.each do |game|
    puts "------------- DEATH BY CAUSE REPORT (MATCH #{game.name}) -------------"
    game.death_report
  end
end


main
