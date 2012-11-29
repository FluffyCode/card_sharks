# war.rb version 0.1

require "card_sharks/deck"
require "card_sharks/player"
require "card_sharks/dealer"

# Rules of the card game "War"
	# As per http://www.activityvillage.co.uk/war_card_game.htm:

	# To start, the cards are dealt to the players and kept face-down. Neither player must look at their cards.
	# Then, both players turn over the top card in their piles and put them face-up in the centre, next to the other
	# player’s card. Whoever has turned over the higher ranking card, never mind which suit it is of, takes up both
	# cards and adds them to the bottom of his pile.
	
	# This then continues until two cards of the same value (eg 2 fours) are placed down together. This constitutes
	# “War”. Both players then take two more cards and put one face-down on top of the card they have already placed
	# in the middle, and one face-up. Whoever puts down the higher ranking face-up card wins all six.
	
	# If, of course, two more same-ranking cards are put down, the state of “War” continues until there is a winner.
	
	# The game is won by the player who manages to collect all the cards.

class War
	def initialize
		@player = Player.new
		@dealer = Dealer.new
	end

	def round_of_war
		# New deck each round
		@deck = Deck.new
		@deck.shuffle!

		# The entire deck is exhausted - half goes to the player...
		26.times { @player.deal(@deck.remove_top_card) }
		# ...and the other half goes to the dealer
		26.times { @dealer.deal(@deck.remove_top_card) }
	end
end

War.new.round_of_war
