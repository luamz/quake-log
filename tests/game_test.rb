require 'minitest/autorun'
require_relative '../models/game.rb'

class GameTest < Minitest::Test
  def setup
    @game = Game.new(1)
  end

  def test_update_player
    @game.update_player(1, "Pedro")
    @game.update_player(27, "Ana")
    assert_equal "Pedro", @game.instance_variable_get(:@players)[1].name
    assert_equal "Ana", @game.instance_variable_get(:@players)[27].name
    assert_equal @game.instance_variable_get(:@players).count, 2
  end

  def test_update_player_already_exists
    @game.update_player(1, "Pedro")
    @game.update_player(1, "Pedro")
    assert_equal "Pedro", @game.instance_variable_get(:@players)[1].name
    assert_equal @game.instance_variable_get(:@players).count, 1
  end

  def test_update_player_renames_player
    @game.update_player(1, "Pedro")
    @game.update_player(1, "João")
    refute_equal  "Pedro", @game.instance_variable_get(:@players)[1].name
    assert_equal "João", @game.instance_variable_get(:@players)[1].name
    assert_equal @game.instance_variable_get(:@players).count, 1
  end

  def test_add_kill
    @game.update_player(1, "Igor")
    @game.update_player(2, "Eduardo")

    @game.add_kill(1, 2, "MOD_LAVA")
    assert_equal 1, @game.instance_variable_get(:@players)[1].kills
    assert_equal 0, @game.instance_variable_get(:@players)[2].kills
  end

  def test_add_kill_world
    @game.update_player(1, "Igor")
    @game.update_player(2, "Eduardo")

    @game.add_kill(1, 2, "MOD_LAVA")
    assert_equal 1, @game.instance_variable_get(:@players)[1].kills

    # When <world> kill a player, that player loses -1 kill score.
    @game.add_kill(Game::WORLD, 1, "MOD_GRENADE")
    assert_equal 0, @game.instance_variable_get(:@players)[1].kills
  end

  def test_match_report
    @game.update_player(1, "Isabella")
    @game.update_player(2, "Hugo")
    @game.add_kill(1, 2, "MOD_ROCKET")
    @game.add_kill(Game::WORLD, 1, "MOD_FALL")
    @game.add_kill(Game::WORLD, 2, "MOD_FALL")

    @game.match_report

    report = JSON.parse(capture_io { @game.match_report }.first)

    # The counter total_kills includes player and world deaths.
    assert_equal 3, report["Game_1"]["total_kills"]

    assert_includes report["Game_1"]["players"][0], 'Isabella'
    assert_includes report["Game_1"]["players"][1], 'Hugo'

    assert_equal report["Game_1"]["kills"]["Isabella"], 0
    assert_equal report["Game_1"]["kills"]["Hugo"], -1

    assert_equal(report["Game_1"]["kills_by_means"],{ "MOD_FALL" => 2, "MOD_ROCKET" => 1 })
  end

  def test_ranking
    @game.update_player(1, "Emilia")
    @game.update_player(2, "Manuel")
    @game.update_player(3, "Simão")
    @game.add_kill(1, 2, "MOD_FALL")
    @game.add_kill(1, 2, "MOD_FALL")
    @game.add_kill(2, 1, "MOD_FALL")

    ranking = @game.ranking

    assert_equal "Emilia", ranking[0].name
    assert_equal 2, ranking[0].kills

    assert_equal "Manuel", ranking[1].name
    assert_equal 1, ranking[1].kills

    assert_equal "Simão", ranking[2].name
    assert_equal 0, ranking[2].kills
  end
end
