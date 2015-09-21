require 'open-uri'
require 'json'
require 'date'

class GameController < ApplicationController
  def game
    @grid = generate_grid(9).join(" ")
    @start_time = Time.now
    @end_time = Time.now + 2
    @attempt = params[:attempt]
  end
  def score
    attempt = params[:attempt]
    grid = params[:grid].split("")
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    @result = run_game(attempt, grid, start_time, end_time)
  end

  private

  ALPHABET = ("A".."Z").to_a
  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    return grid_size.times.map { ALPHABET.sample }
  end

  def compare(attempt, grid)
    grid = grid.dup
    attempt.upcase.split("").all? do |letter|
      index = grid.index(letter)
      grid.delete_at(index) if index
      index
    end
  end

  def valid_word(attempt, start_time, end_time, hash)
    if hash.key?("term0")
      value = hash.fetch("term0").fetch("PrincipalTranslations").fetch("0").fetch("FirstTranslation").fetch("term")
      timer = end_time - start_time
      score = (((attempt.length * 10) / timer)*100).round()
      return { time: timer, translation: value, score: score, message: "well done" }
    else
      return { time: timer, translation: nil, score: 0, message: "not an english word" }
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result

    if !compare(attempt, grid)
      return {message: "The game is mad! This is not in the grid!" }

    else
      stream = open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}")
      json = stream.read
      hash = JSON.parse(json)

      valid_word(attempt, start_time, end_time, hash)
    end
  end
end
