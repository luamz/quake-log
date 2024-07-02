require 'minitest/autorun'
require_relative '../src/models/game'
require_relative '../src/utils/parser'

class ParseGameTest < Minitest::Test
  def setup
    @log_filename = "test.log"
    @log_content = <<~LOG
      ClientUserinfoChanged: 1 n\\Ana\\
      ClientUserinfoChanged: 2 n\\Beatriz\\
      ClientUserinfoChanged: 3 n\\Camilo\\
      Kill: 2 3 10: Ana killed Camila by MOD_ROCKET
      Kill: 1022 1 11: <world> killed Beatriz by MOD_FALL
      0:00 InitGame: 2
      ClientUserinfoChanged: 4 n\\Dado\\
      Kill: 1022 4 11: <world> killed Dado by MOD_FALL
    LOG

    File.write(@log_filename, @log_content)
  end

  def teardown
    File.delete(@log_filename) if File.exist?(@log_filename)
  end

  def test_parse_game
    @file = File.open(@log_filename, "r")

    game = Parser.parse_game(@file, 1)
    assert_equal game.name, "Game_1"

    report = JSON.parse(capture_io { game.match_report }.first)

    assert_equal 2, report["Game_1"]["total_kills"]

    assert_includes report["Game_1"]["players"][0], 'Ana'
    assert_includes report["Game_1"]["players"][1], 'Beatriz'
    assert_includes report["Game_1"]["players"][2], 'Camilo'

    assert_equal 3, report["Game_1"]["players"].count

    assert_equal report["Game_1"]["kills"]["Ana"], -1
    assert_equal report["Game_1"]["kills"]["Beatriz"], 1
    assert_equal report["Game_1"]["kills"]["Camilo"], 0
  end
end


class ParseLogTest < Minitest::Test
  def setup
    @log_filename = "test.log"
    @shutdown_filename = "shutdown_test.log"

    @log_content = <<~LOG
      0:00 InitGame: 1
      ClientUserinfoChanged: 1 n\\Ana\\
      ClientUserinfoChanged: 2 n\\Beatriz\\
      Kill: 1 2 10: Ana killed Beatriz by MOD_ROCKET
      Kill: 1022 2 11: <world> killed Beatriz by MOD_FALL
      0:00 InitGame: 2
      ClientUserinfoChanged: 4 n\\Dado\\
      Kill: 1022 4 11: <world> killed Dado by MOD_FALL
    LOG

    @log_content_shutdown = <<~LOG
      0:00 InitGame: 1
      1:00 ClientUserinfoChanged: 1 n\\Ana\\
      1:30 ClientUserinfoChanged: 2 n\\Beatriz\\
      2:00 Kill: 1 2 10: Ana killed Beatriz by MOD_ROCKET
      3:00 Kill: 1022 2 11: <world> killed Beatriz by MOD_FALL
      5:37 ShutdownGame:
      5:37 ------------------------------------------------------------
      5:37 ------------------------------------------------------------
      5:38 InitGame: 1
      5:39 ClientUserinfoChanged: 1 n\\Dado\\
      7:50 Kill: 1022 1 11: <world> killed Dado by MOD_FALL
    LOG

    File.write(@log_filename, @log_content)
    File.write(@shutdown_filename, @log_content_shutdown)
  end

  def teardown
    File.delete(@log_filename) if File.exist?(@log_filename)
    File.delete(@shutdown_filename) if File.exist?(@shutdown_filename)
  end

  def test_parse_game
    @file = File.open(@log_filename, "r")

    games = Parser.parse_log(@file)

    assert_equal 2, games.count

    report = JSON.parse(capture_io { games[0].match_report }.first)
    report2 = JSON.parse(capture_io { games[1].match_report }.first)

    refute_nil report["Game_1"]
    assert_includes report["Game_1"]["players"][0], 'Ana'
    assert_includes report["Game_1"]["players"][1], 'Beatriz'
    assert_equal report["Game_1"]["kills"]["Ana"], 1
    assert_equal report["Game_1"]["kills"]["Beatriz"], -1

    refute_nil report2["Game_2"]
    assert_includes report2["Game_2"]["players"][0], 'Dado'
    assert_equal report2["Game_2"]["kills"]["Dado"], -1
  end


  # Testing the case where a game is shutdown and the timer stops
  # but then the game proceeds and the timer continues where it had stopped
  def test_parse_game_shutdown
    @file = File.open(@shutdown_filename, "r")

    games = Parser.parse_log(@file)

    assert_equal 1, games.count

    report = JSON.parse(capture_io { games[0].match_report }.first)

    refute_nil report["Game_1"]
    assert_includes report["Game_1"]["players"][0], 'Dado'
    assert_includes report["Game_1"]["players"][1], 'Beatriz'
    assert_equal report["Game_1"]["kills"]["Dado"], 0
    assert_equal report["Game_1"]["kills"]["Beatriz"], -1

  end
end

