require 'json'

class Hangman
  attr_accessor :secret_word, :guesses, :correct_letters, :incorrect_letters

  MAX_GUESSES = 7

  def initialize
    if load_game?
      load_game
    else
      @dictionary = load_dictionary
      @secret_word = select_random_word
      @guesses = MAX_GUESSES
      @correct_letters = Array.new(@secret_word.length, '_')
      @incorrect_letters = []
    end
  end

  def guess(letter)
    letter.downcase!
    if @secret_word.include?(letter)
      @secret_word.chars.each_with_index do |char, index|
        @correct_letters[index] = char if char == letter
      end
    else
      @incorrect_letters << letter
      @guesses -= 1
    end
  end

  def display_status
    puts "Secret word: #{correct_letters.join(' ')}"
    puts "Incorrect letters: #{incorrect_letters.join(', ')}"
    puts "Remaining guesses: #{@guesses}"
  end

  def game_over?
    @guesses == 0 || @correct_letters.join('') == @secret_word
  end

  def prompt_guess
    puts "Enter a letter to guess, or 'save' to save the game:"
    input = gets.chomp.downcase
    if input == 'save'
      save_game
    else
      guess(input)
    end
  end

  def save_game
    data = {
      secret_word: @secret_word,
      guesses: @guesses,
      correct_letters: @correct_letters,
      incorrect_letters: @incorrect_letters
    }
    File.write('hangman_save.json', data.to_json)
    puts "Game saved successfully."
    exit
  end

  def load_game
    data = JSON.parse(File.read('hangman_save.json'))
    @secret_word = data['secret_word']
    @guesses = data['guesses']
    @correct_letters = data['correct_letters']
    @incorrect_letters = data['incorrect_letters']
  end

  def load_game?
    puts "Do you want to load a saved game? (yes/no)"
    gets.chomp.downcase == 'yes'
  end

  private

  def load_dictionary
    File.readlines('google_dictionary.txt').map(&:chomp)
  end

  def select_random_word
    @dictionary.select { |word| word.length.between?(5, 12) }.sample
  end
end

game = Hangman.new

until game.game_over?
  game.display_status
  game.prompt_guess
end

if game.guesses == 0
  puts "Game over! The word was: #{game.secret_word}"
else
  puts "Congratulations! You've guessed the word: #{game.secret_word}"
end