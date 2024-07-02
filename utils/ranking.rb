module Ranking

  def self.global_ranking(games)
    global_ranking = Hash.new { |hash, key| hash[key] = { name: nil, kills: 0 } }
    games.each do |game|
      game.ranking.each do |player|
        global_ranking[player.id][:name] = player.name
        global_ranking[player.id][:kills] += player.kills
      end
    end
    sorted_global_ranking = global_ranking.sort_by { |id, info| -info[:kills] }

    sorted_global_ranking.each_with_index do |(player_id, info), index|
      puts "#{index + 1}. #{info[:name]} - Kills: #{info[:kills]}"
    end
  end

end