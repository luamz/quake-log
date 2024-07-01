class Player
  attr_accessor :name, :kills

  def initialize(id, name)
    @id = id
    @name = name
    @kills = 0
  end

  def increment_kills
    @kills += 1
  end
end

class Game
  attr_accessor :players, :total_kills

  WORLD = 1022 # id de <world>

  def initialize(game_id)
    @game_name = "Game_#{game_id}"
    @players = {}
    @total_kills = 0
  end

  def update_player(id, name)
    if @players[id] and @players[id].name != name
      @players[id].name = name
    else
      @players.store(id, Player.new(id, name))
    end
  end

  def increment_total_kills
    @total_kills += 1
  end

  def add_kill(killer_id, killed_id, cause)

  end

end

def parse_game(file, game_id)
  game = Game.new(game_id)

  file.each_line do |line|

    if line.include?("InitGame")

      file.pos = file.pos - line.bytesize - 1
      break

    elsif (player_changed = line.match(/^*ClientUserinfoChanged: (\d) n\\(.+)\\/))
      id, name = player_changed.captures
      game.update_player(id, name)

    elsif (kill = line.match(/Kill: (\d) (\d) \d: .+ killed .+ by (.+)/))
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
      if line.include?("InitGame")
        game_count += 1
        # puts "--------- Iniciando Jogo #{game_count }--------"
        current_game = parse_game(file, game_count)
        # puts "--------- Finalizando Jogo #{game_count} --------"
        games << current_game
      end
    end
  end
  games
end

# Exemplo de uso
filename = "qgames.log"
games = parse_log(filename)
# games.each do |game|
#     game.print_game_info
# end