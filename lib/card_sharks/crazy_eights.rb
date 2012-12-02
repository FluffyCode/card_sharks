# crazy_eights.rb version 0.1

require "card_sharks/deck"
require "card_sharks/player"
require "card_sharks/dealer"

# Game rules:
	# As per http://www.pagat.com/eights/crazy8s.html

	# Use standard 52-card deck.
	# 7 cards are dealt to both the player and dealer.
	# Remaining cards are placed face-down in a draw-pile.
	# The top card in the draw-pile is then played face-up.

	# Players take turns playing cards on top of the face-up (discard) pile.
	# If the face-up card is not an 8, only cards of the same rank or suit can be played on it.
		# Ie, if the card is a 4 of Spades, the only cards that can be played on top of it are
		# a 4 of any other suit, OR any rank as long as it is a Spade.

		# Exception: an 8 can be played on any suit/rank.  This is where "Crazy Eights" gets "crazy."

	# Eights can be played on any card.
	# When an 8 is played, the player placing the card declares a suit.
		# Only cards with the declared suit can be placed on top of the "crazy" eight.

		# Exception: players can place another 8 on top of an 8, and declare a new suit, themselves.

	# The first player to get rid of all their cards wins.
	# Losing player scores "penalty points" based on what cards they have left:
		# Any eight = 50 points.
		# Jack, Queen, King = 10 points.
		# All other cards at face value (Ace = 1, 2 = 2, etc...)

	# If a player cannot play a legal card, they must draw from the draw-pile.
	# If no cards remain in the draw-pile, play continues as normal without drawing.



class CrazyEights
	def initialize
		@player = Player.new
		@dealer = Dealer.new
	end

	def round_of_crazy_eights
		@deck = Deck.new
		@deck.shuffle!

		7.times { @player.deal(@deck.remove_top_card) }
		7.times { @dealer.deal(@deck.remove_top_card) }

		# Next card taken from the deck becomes the start of the discard pile
		@discard_pile = @deck.remove_top_card

		# Players turn
		def players_turn
			puts ""
			puts "The top card on the discard pile is: #{@discard_pile}."
			puts "What card would you like to play?  Your hand contains:"
			puts "#{@player.tell_hand}"
			puts ""
			puts "If you can/do not wish to play, type 'pass' to pass."

			@user_input = gets.chomp

			if @user_input.downcase == "pass"	# if the player passes...
				if @deck.deck(0) != nil	# ...and cards still remain in the draw pile...
					@player.deal(@deck.remove_top_card)	# ...the player draws from the top of the draw pile...
					puts "You draw #{@player.hand[-1]} from the draw pile."
					players_turn
				else	# ...else, if no cards remain in the draw pile...
					dealers_turn	# ...skip drawing (as it cannot be done), and go to the dealer's turn
				end

			elsif @user_input.to_i > 0 && @user_input.to_i < @player.hand.length + 1
				puts "You chose to play: #{@player.hand[@user_input.to_i - 1]}."

			else
				puts ""
				puts "Error: was expecting 'pass' or an integer between 1 and #{@player.hand.length}."
				players_turn
			end

		end	# end of players_turn

		# Dealers turn
		def dealers_turn

		end	# end of dealers_turn



		players_turn
	end # end of round_of_crazy_eights

end	# end of CrazyEights class

CrazyEights.new.round_of_crazy_eights
