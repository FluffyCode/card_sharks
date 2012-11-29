# add_a_card.rb version 0.1

require "card_sharks/deck"

# Game rules for "Add A Card"
	# From http://tlc.howstuffworks.com/family/card-games-for-kids3.htm

	# Use a standard deck of 52 cards.
	# Deal cards, 2 at a time - the user has a set amount of time to add the cards together.
	# Cards are worth face-value, with the exception of Aces, Jacks, Queens and Kings (all of which == 10).



class Add_A_Card
	def strip_suit(card)
		card.to_s.gsub(/( of Clubs)/, "").gsub(/( of Diamonds)/, "").gsub(/( of Hearts)/, "").gsub(/( of Spades)/, "")
	end

	def round_of_add_a_card
		# Create the deck and shuffle it
		@deck = Deck.new
		@deck.shuffle!

		# Prompt player for preferred difficulty (1-5; lower number = hardest, highest number = easiest)
		puts ""
		puts "Which difficulty level would you like to play at? Input a number between 1 and 5:"
		puts "1 = hardest, 2 = hard, 3 = medium, 4 = easy, 5 = easiest."

		@user_difficulty = gets.chomp.to_i

		until (@user_difficulty <= 5) && (@user_difficulty >= 1)
			puts ""
			puts "Error: expected a one-digit number between 1 and 5."
			@user_difficulty = gets.chomp.to_i
		end



		# Main game loop
		until @deck.length == 0	# Until all cards in the deck have been exhausted, the game is played
			@this_round_of_cards = []

			2.times { @this_round_of_cards << strip_suit(@deck.remove_top_card) }

			puts ""
			puts "This round, the two cards are: #{@this_round_of_cards}."
		end	# end main game loop
	end	# end round_of_add_a_card

end

Add_A_Card.new.round_of_add_a_card
