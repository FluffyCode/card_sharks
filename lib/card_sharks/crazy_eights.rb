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

		def check_for_match(discard_pile, card_being_played)
			if card_being_played::rank == discard_pile::rank || card_being_played::suit == discard_pile::suit || card_being_played::rank == "Eight"
				true
			end
		end

		def players_turn
			puts ""
			puts "The top card on the discard pile is: #{@discard_pile}."
			puts "What card would you like to play?  Your hand contains:"
			puts "#{@player.tell_hand}"
			puts ""
			puts "If you can/do not wish to play, type 'pass' to pass."

			@user_input = gets.chomp

			if @user_input.downcase == "pass"
				if @deck.deck(0) != nil
					@player.deal(@deck.remove_top_card)
					puts "You draw #{@player.hand[-1]} from the draw pile."
					players_turn
				else
					dealers_turn
				end

			else
				@user_input = @user_input.to_i
			
				if @user_input > 0 && @user_input < @player.hand.length + 1
					@user_input -= 1

					if check_for_match(@discard_pile, @player.hand[@user_input])
						puts ""
						puts "You play your #{@player.hand[@user_input]}."
						@discard_pile = @player.hand.delete_at(@user_input)

						intermediary_stage("player")
						
					else
						puts ""
						puts "You cannot play #{@player.hand[@user_input]} - either rank or suit (or both) does not match."
						players_turn
					end

				else
					puts ""
					puts "Error: was expecting 'pass' or an integer between 1 and #{@player.hand.length}."
					players_turn
				end
			end

		end

		# Intermediary stage - check for the play of 8's here
		def intermediary_stage(player)
			is_an_eight = true if @discard_pile::rank == "Eight"

			if player == "player"	# If the player just had their turn...
				if is_an_eight	# ...and it was an eight...
					puts ""
					puts "You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades."

					@new_suit = gets.chomp.downcase.capitalize!	# ...the player nominates a new suit...
					if @new_suit == "Clubs" || @new_suit == "Diamonds" || @new_suit == "Hearts" || @new_suit == "Spades"
						@discard_pile::suit = @new_suit	# change the suit of the card on the discard pile
						puts ""
						puts "You chose to change the playable suit to: #{@new_suit}."
						puts ""
						puts "The top card on the discard pile is: #{@discard_pile}."
					else # player gets put back into the loop on a bad input
						puts ""
						puts "Error: was expecting a string for a new suit."
						intermediary_stage(player)
					end
				else	# otherwise, go to the dealer's turn
					dealers_turn
				end

			elsif player == "dealer"
				if is_an_eight	# if the dealer played an eight...
					random_num = Math.floor(Math.random(@dealer.hand.length))

					@discard_pile::suit = @dealer.hand[random_num]::suit

					puts ""
					puts "The dealer played an Eight, and decided to change the suit to #{@dealer.hand[random_num]::suit}."
					puts ""
					puts "The top card on the discard pile is: #{@discard_pile}."
				else	# if it wasn't an eight...
					players_turn
				end
			
			else
				if player == "player"
					dealers_turn
				else
					players_turn
				end
			end
		end

		# Dealers turn
		def dealers_turn
			@dealer.hand.each do |card|	# go through each card in the dealer's hand in turn...
				if check_for_match(@discard_pile, card)	# ...and if it can be played, the dealer does so
					puts ""
					puts "The dealer plays their #{card]}."
					@discard_pile = @dealer.hand.delete(card)

					intermediary_stage("dealer")
				end
			end	# end of each-do
		end	# end of dealers_turn



		players_turn
	end # end of round_of_crazy_eights

end	# end of CrazyEights class

CrazyEights.new.round_of_crazy_eights

# Current issue:
	# somewhere in the intermediary_stage method, lines 115/116, the code is not taking "clubs", "diamonds",
	# "hearts" or "spades" - it deems everything an invalid input (even invalid input - but that's a good thing)
	# Tl;dr, infinite loops.  Figure it out, fix it.
	