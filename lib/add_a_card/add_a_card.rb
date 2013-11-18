# add_a_card.rb version 1.0

require_relative "../master/deck"
require_relative "add_a_card_value"
require "timeout"

# Game rules for "Add A Card"
  # From http://tlc.howstuffworks.com/family/card-games-for-kids3.htm

  # Use a standard deck of 52 cards.
  # Deal cards, 2 at a time - the user has a set amount of time to add the cards together.
  # Cards are worth face-value, with the exception of Aces, Jacks, Queens and Kings (all of which == 10).



class AddACard
  def initialize
    @deck = Deck.new
    @deck.shuffle!

    @countdown_timer = 1 + set_difficulty

    @num_correct = 0
  end

  def set_difficulty
    # Prompt player for preferred difficulty (1-5; lower number = hardest, highest number = easiest)
    puts ""
    puts "Which difficulty level would you like to play at? Input a number between 1 and 5:"
    puts "1 = hardest, 2 = hard, 3 = medium, 4 = easy, 5 = easiest."

    user_difficulty = gets.chomp.to_i

    until (user_difficulty <= 5) && (user_difficulty >= 1)
      puts ""
      puts "Error: expected a one-digit number between 1 and 5."
      user_difficulty = gets.chomp.to_i
    end

    user_difficulty
  end

  def evaluate_this_round(cards)
    AddACardValue.new(cards).value
  end

  def round_of_add_a_card
    until @deck.length == 0 # Until all cards in the deck have been exhausted, the game is played
      this_round_of_cards = []

      2.times { this_round_of_cards << @deck.remove_top_card }

      puts ""
      puts "What is the sum of:"
      puts "#{this_round_of_cards.join(" - ")}"

      begin
        Timeout::timeout(@countdown_timer) {
          user_num = gets.chomp.to_i

          @num_correct += 1 if user_num == evaluate_this_round(this_round_of_cards)
        }
      rescue
      end
    end # end main game loop

    puts ""
    puts "Out of 26 rounds, you got #{@num_correct} correct."
  end # end round_of_add_a_card

end

AddACard.new.round_of_add_a_card
