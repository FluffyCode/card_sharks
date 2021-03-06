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

    @num_correct = 0
    @score = 0

    @eval = AddACardValue.new

    @difficulty = set_difficulty
    @countdown_timer = 1 + @difficulty[:timer]
  end

  def set_difficulty
    # Prompt player for preferred difficulty (1-5; lower number = hardest, highest number = easiest)
    puts ""
    puts "Which difficulty level would you like to play at? Input a number between 1 and 5:"
    puts "5 = hardest, 4 = hard, 3 = medium, 2 = easy, 1 = easiest."

    user_difficulty = gets.chomp.to_i

    until (user_difficulty <= 5) && (user_difficulty >= 1)
      puts ""
      puts "Error: expected a one-digit number between 1 and 5."
      user_difficulty = gets.chomp.to_i
    end

    case user_difficulty
      when 1
        { difficulty: "easiest", score_multiplier: 1, timer: 5 }
      when 2
        { difficulty: "easy", score_multiplier: 2, timer: 4 }
      when 3
        { difficulty: "normal", score_multiplier: 3, timer: 3 }
      when 4
        { difficulty: "hard", score_multiplier: 4, timer: 2 }
      when 5
        { difficulty: "hardest", score_multiplier: 5, timer: 1 }
    end
  end

  def round_of_add_a_card
    until @deck.length == 0 # Until all cards in the deck have been exhausted, the game is played
      cards_this_round = []
      2.times { cards_this_round << @deck.remove_top_card }
      @eval.cards(cards_this_round)
      value = @eval.value

      puts ""
      puts "What is the sum of:"
      puts "#{cards_this_round.join(" - ")}"

      begin
        Timeout::timeout(@countdown_timer) {
          user_num = gets.chomp.to_i

          if user_num == value
            @num_correct += 1
            @score += (value * @difficulty[:score_multiplier])
          end
        }
      rescue
      end
    end # end main game loop

    puts ""
    puts "Out of 26 rounds, you got #{@num_correct} correct."
    puts "You scored #{@score} out of a possible #{376 * @difficulty[:score_multiplier]} for this difficulty (#{@difficulty[:difficulty]})."
  end # end round_of_add_a_card

end

AddACard.new.round_of_add_a_card
