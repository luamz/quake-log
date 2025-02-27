require 'minitest/autorun'
require_relative '../models/game.rb'
require_relative '../utils/ranker.rb'

class GlobalRankingTest < Minitest::Test
  def setup
    @game1 = Game.new(1)
    @game1.update_player(1, "Daniel")
    @game1.update_player(2, "Luam")
    @game1.update_player(3, "Jéssica")
    @game1.add_kill(1, 2, "MOD_ROCKET")
    @game1.add_kill(1, 3, "MOD_ROCKET")
    @game1.add_kill(Game::WORLD, 1, "MOD_FALL")

    @game2 = Game.new(2)
    @game2.update_player(1, "Daniel")
    @game2.update_player(4, "Maria")
    @game2.update_player(5, "Paula")
    @game2.add_kill(4, 5, "MOD_ROCKET")
    @game2.add_kill(1, 4, "MOD_ROCKET")
    @game2.add_kill(5, 1, "MOD_ROCKET")
  end

  def test_global_ranking
    expected_output = <<~OUTPUT
      1. Daniel (id: 1) - Kills: 2
      2. Maria (id: 4) - Kills: 1
      3. Paula (id: 5) - Kills: 1
      4. Luam (id: 2) - Kills: 0
      5. Jéssica (id: 3) - Kills: 0
    OUTPUT

    games = [@game1, @game2]
    output = capture_io { Ranker.global_ranking(games) }.first

    assert_equal expected_output.strip, output.strip
  end


  def test_global_ranking_renaming_player
    @game2.update_player(1, "Erick")

    wrong_output = <<~OUTPUT
    1. Daniel (id: 1) - Kills: 2
      2. Maria (id: 4) - Kills: 1
      3. Paula (id: 5) - Kills: 1
      4. Luam (id: 2) - Kills: 0
      5. Jéssica (id: 3) - Kills: 0
    OUTPUT

    expected_output = <<~OUTPUT
      1. Erick (id: 1) - Kills: 2
      2. Maria (id: 4) - Kills: 1
      3. Paula (id: 5) - Kills: 1
      4. Luam (id: 2) - Kills: 0
      5. Jéssica (id: 3) - Kills: 0
    OUTPUT

    games = [@game1, @game2]
    output = capture_io { Ranker.global_ranking(games) }.first

    refute_equal wrong_output.strip, output.strip
    assert_equal expected_output.strip, output.strip
  end


  def test_global_tie

    @game2.add_kill(4, 1, "MOD_ROCKET")


    expected_output = <<~OUTPUT
      1. Daniel (id: 1) - Kills: 2
      2. Maria (id: 4) - Kills: 2
      3. Paula (id: 5) - Kills: 1
      4. Luam (id: 2) - Kills: 0
      5. Jéssica (id: 3) - Kills: 0
    OUTPUT

    games = [@game1, @game2]
    output = capture_io { Ranker.global_ranking(games) }.first

    assert_equal expected_output.strip, output.strip
  end
end
