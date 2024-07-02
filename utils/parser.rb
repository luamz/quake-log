require_relative '../models/game'

module Parser
  def self.parse_game(file, game_id)
    game = Game.new(game_id)

    file.each_line do |line|

      # Skip to the next match on the file if the current game is over
      # Game is only over when time restarts 0:00 ------------------------------------------------------------
      # A new match starts a new timer with 0:00 InitGame: (...)
      if line.include?("0:00 InitGame")
        file.pos = file.pos - line.bytesize - 1 # Rewinds file by one line
        break

      # Collect Clients
      elsif (player_changed = line.match(/^*ClientUserinfoChanged: (\d) n\\(.+?)\\.*/))

        # Each Player has their unique id and a changeable name
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

  def self.parse_log(filename)
    games = []
    game_count = 0

    File.open(filename, "r") do |file|
      file.each_line do |line|

        # Groups information for each game in the file
        if line.include?("0:00 InitGame")
          game_count += 1
          current_game = parse_game(file, game_count)
          games << current_game
        end

      end
    end

    games
  end
end