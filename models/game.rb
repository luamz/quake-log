require_relative 'player'
require 'json'

class Game
  attr_accessor :name

  WORLD = "1022" # <world> id

  def initialize(game_id)
    @name = "Game_#{game_id}"
    @players = {}
    @kills_by_means = {}
    @total_kills = 0
  end

  def update_player(id, name)
    if @players[id] and @players[id].name != name
      @players[id].name = name
    else
      @players.store(id, Player.new(id, name))
    end
  end

  def add_kill(killer_id, killed_id, cause)
    if killer_id == WORLD
      @players[killed_id].kills -= 1
    else
      @players[killer_id].kills += 1
    end

    @kills_by_means[cause] = (@kills_by_means[cause] || 0) + 1
    @total_kills += 1
  end

  def match_report
    names = @players.values.map(&:name)
    kills = @players.values.each_with_object({}) do |player, hash|
      hash[player.name] = player.kills
    end

    summary = {
      @name => {
        "total_kills" => @total_kills,
        "players" => names,
        "kills" => kills
      }
    }

    puts JSON.pretty_generate(summary)
  end

  def ranking
    @players.values.sort_by { |player| -player.kills }
  end

  def death_report
    kills = @kills_by_means.sort_by { |cause, kills| -kills }.to_h
    summary = { @name => { "kills_by_means": kills } }
    puts JSON.pretty_generate(summary)
  end

end