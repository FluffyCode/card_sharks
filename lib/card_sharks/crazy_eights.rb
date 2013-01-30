# crazy_eights.rb version 2.3

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
		5.times { @deck.shuffle! }

		7.times { @player.deal(@deck.remove_top_card) }
		7.times { @dealer.deal(@deck.remove_top_card) }

		# Next card taken from the deck becomes the start of the discard pile
		@discard_pile = @deck.remove_top_card

		def check_for_match(card_being_played)
			if card_being_played::rank == @discard_pile::rank || card_being_played::suit == @discard_pile::suit || card_being_played::rank == "Eight"
				true
			end
		end

		def players_turn
			puts ""
			puts "The top card on the discard pile is: #{@discard_pile}."
			puts "What card would you like to play?  Your hand contains:"
			puts "#{@player.tell_hand_numbered}"
			puts ""
			puts "If you can/do not wish to play, type 'pass' to pass."

			@user_input = gets.chomp

			if @user_input.downcase == "pass"
				if @deck.deck(0) != nil
					@player.deal(@deck.remove_top_card)
					puts ""
					puts "You draw #{@player.hand[-1]} from the draw pile."
					players_turn
				else
					time_to_reshuffle_deck("dealer")
					dealers_turn
				end

			else
				@user_input = @user_input.to_i
			
				if @user_input > 0 && @user_input < @player.hand.length + 1
					@user_input -= 1

					if check_for_match(@player.hand[@user_input])
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

		end	# end of players_turn

		# Determine if conditions are appropriate for deck reshuffling
		def time_to_reshuffle_deck(player)
			time_to_reshuffle = false

			if @deck.length == 0
				@player.hand.each do |card|
					if check_for_match(card)
					else
						time_to_reshuffle = true
					end
				end

				@dealer.hand.each do |card|
					if check_for_match(card)
					else
						time_to_reshuffle = true
					end
				end
			end

			if time_to_reshuffle
				replace_deck(player)
			end
		end

		# Intermediary stage - check for game overs, & the play of 8's here
		def intermediary_stage(player)
			time_to_reshuffle_deck(player)

			is_an_eight = true if @discard_pile::rank == "Eight"

			if @player.hand.length == 0
				puts ""
				puts "You were the first to clear all cards from your hand - you win!"
				exit 0
			elsif @dealer.hand.length == 0
				puts ""
				puts "The dealer was first to clear their hand of all cards and won this game."
				exit 0
			end

			if is_an_eight
				if player == "player"
					puts ""
					puts "You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades."

					@new_suit = gets.chomp.downcase.capitalize!
					if @new_suit == "Clubs" || @new_suit == "Diamonds" || @new_suit == "Hearts" || @new_suit == "Spades"
						@discard_pile::suit = @new_suit
						puts ""
						puts "You chose to change the playable suit to: #{@new_suit}."
						puts ""
						puts "The top card on the discard pile is: #{@discard_pile}."

						dealers_turn
					else
						puts ""
						puts "Error: was expecting a string for a new suit."
						intermediary_stage(player)
					end

				elsif player == "dealer"
					random_num = rand(@dealer.hand.length)

					@discard_pile::suit = @dealer.hand[random_num]::suit

					puts ""
					puts "The dealer played an Eight, and decided to change the suit to #{@dealer.hand[random_num]::suit}."

					players_turn
				end
			end
			
			invert_player_turn(player)
		end	# end of intermediary_stage

		# Dealers turn
		def dealers_turn
			can_play_these = []

			@dealer.hand.each do |card|
				if check_for_match(card)
					can_play_these << card
				end
			end

			if can_play_these.length > 0
				chosen_card = can_play_these[rand(can_play_these.length)]

				puts ""
				puts "The dealer plays their #{chosen_card}."
				@discard_pile = @dealer.hand.delete(chosen_card)

				intermediary_stage("dealer")
			else
				if @deck.deck(0) != nil
					@dealer.deal(@deck.remove_top_card)
					puts ""
					puts "The dealer was unable to play a card, and draws from the draw pile."
					dealers_turn
				else
					puts ""
					puts "The dealer was unable to play a card."
					time_to_reshuffle_deck("player")
					players_turn
				end	
			end
		end	# end of dealers_turn

		def go_to_player_turn(player)
			players_turn if (player == "player")
			dealers_turn if (player == "dealer")
		end

		def invert_player_turn(player)
			players_turn if (player == "dealer")
			dealers_turn if (player == "player")
		end

		# Deck reshuffling (in case no legal plays can be made && draw pile is empty)
		def replace_deck(player)
			puts ""
			puts "The draw pile is empty, and no plays can be made."

			@cards_to_discard = []

			@player.hand.each do |card|
				@cards_to_discard << card
			end

			@dealer.hand.each do |card|
				@cards_to_discard << card
			end

			@deck = Deck.new

			until @deck.length == (52 - @cards_to_discard.length)
				@deck.self.each do |card_a|
					@cards_to_discard.each do |card_b|
						@deck.delete(card_a) if card_a == card_b
					end
				end
			end

			5.times { @deck.shuffle! }

			@discard_pile = @deck.remove_top_card

			puts "The discard pile has been reshuffled into the draw pile."

			go_to_player_turn(player)
		end

		# Starting the game:
		players_turn
	end # end of round_of_crazy_eights

end	# end of CrazyEights class

CrazyEights.new.round_of_crazy_eights
