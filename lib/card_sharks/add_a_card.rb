# add_a_card.rb version 0.1

require "card_sharks/deck"

# Game rules for "Add A Card"
	# From http://tlc.howstuffworks.com/family/card-games-for-kids3.htm

	# Use a standard deck of 52 cards.
	# Deal cards, 2 at a time - the user has a set amount of time to add the cards together.
	# Cards are worth face-value, with the exception of Aces, Jacks, Queens and Kings (all of which == 10).

class Add_A_Card
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

	
end

Add_A_Card.new
