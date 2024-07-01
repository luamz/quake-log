require 'minitest/autorun'
require_relative '../models/game'
require_relative '../utils/parsers'

class ParseGameTest < Minitest::Test
  def setup
    @log_filename = "test.log"
    @log_content = <<~LOG
      ClientUserinfoChanged: 1 n\\Ana\\
      ClientUserinfoChanged: 2 n\\Beatriz\\
      ClientUserinfoChanged: 3 n\\Camilo\\
      Kill: 2 3 10: Ana killed Camila by MOD_ROCKET
      Kill: 1022 1 11: <world> killed Beatriz by MOD_FALL
      InitGame: 2
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

    game = parse_game(@file, 1)
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
    @log_content = <<~LOG
      InitGame: 1
      ClientUserinfoChanged: 1 n\\Ana\\
      ClientUserinfoChanged: 2 n\\Beatriz\\
      Kill: 1 2 10: Ana killed Beatriz by MOD_ROCKET
      Kill: 1022 2 11: <world> killed Beatriz by MOD_FALL
      InitGame: 2
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

    games = parse_log(@file)

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
end

