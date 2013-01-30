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

			intermediary_stage(player)
		end

		# Starting the game:
		players_turn
	end # end of round_of_crazy_eights

end	# end of CrazyEights class

CrazyEights.new.round_of_crazy_eights



# First almost-completely issue-free round of Crazy Eights.

# The top card on the discard pile is: Ace of Diamonds.
# What card would you like to play?  Your hand contains:
# Seven of Clubs (1), Nine of Clubs (2), Ten of Diamonds (3), Six of Clubs (4), Eight of Spades (5), Nine of Diamonds (6), Four of Hearts (7)

# If you can/do not wish to play, type 'pass' to pass.
# 3

# You play your Ten of Diamonds.

# The dealer plays their Three of Diamonds.

# The top card on the discard pile is: Three of Diamonds.
# What card would you like to play?  Your hand contains:
# Seven of Clubs (1), Nine of Clubs (2), Six of Clubs (3), Eight of Spades (4), Nine of Diamonds (5), Four of Hearts (6)

# If you can/do not wish to play, type 'pass' to pass.
# 5

# You play your Nine of Diamonds.

# The dealer plays their Four of Diamonds.

# The top card on the discard pile is: Four of Diamonds.
# What card would you like to play?  Your hand contains:
# Seven of Clubs (1), Nine of Clubs (2), Six of Clubs (3), Eight of Spades (4), Four of Hearts (5)

# If you can/do not wish to play, type 'pass' to pass.
# 5

# You play your Four of Hearts.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Eight of Hearts.

# The dealer played an Eight, and decided to change the suit to Diamonds.

# The top card on the discard pile is: Eight of Diamonds.
# What card would you like to play?  Your hand contains:
# Seven of Clubs (1), Nine of Clubs (2), Six of Clubs (3), Eight of Spades (4)

# If you can/do not wish to play, type 'pass' to pass.
# 4

# You play your Eight of Spades.

# You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades.
# clubs

# You chose to change the playable suit to: Clubs.

# The top card on the discard pile is: Eight of Clubs.

# The dealer plays their Two of Clubs.

# The top card on the discard pile is: Two of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Clubs (1), Nine of Clubs (2), Six of Clubs (3)

# If you can/do not wish to play, type 'pass' to pass.
# 1

# You play your Seven of Clubs.

# The dealer plays their Seven of Diamonds.

# The top card on the discard pile is: Seven of Diamonds.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Nine of Hearts from the draw pile.

# The top card on the discard pile is: Seven of Diamonds.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Six of Diamonds from the draw pile.

# The top card on the discard pile is: Seven of Diamonds.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Six of Diamonds (4)

# If you can/do not wish to play, type 'pass' to pass.
# 4

# You play your Six of Diamonds.

# The dealer plays their Five of Diamonds.

# The top card on the discard pile is: Five of Diamonds.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Ace of Hearts from the draw pile.

# The top card on the discard pile is: Five of Diamonds.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Ace of Clubs from the draw pile.

# The top card on the discard pile is: Five of Diamonds.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Queen of Diamonds from the draw pile.

# The top card on the discard pile is: Five of Diamonds.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Queen of Diamonds (6)

# If you can/do not wish to play, type 'pass' to pass.
# 6

# You play your Queen of Diamonds.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Queen of Spades.

# The top card on the discard pile is: Queen of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Three of Hearts from the draw pile.

# The top card on the discard pile is: Queen of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Jack of Diamonds from the draw pile.

# The top card on the discard pile is: Queen of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6), Jack of Diamonds (7)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Two of Diamonds from the draw pile.

# The top card on the discard pile is: Queen of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6), Jack of Diamonds (7), Two of Diamonds (8)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw King of Hearts from the draw pile.

# The top card on the discard pile is: Queen of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6), Jack of Diamonds (7), Two of Diamonds (8), King of Hearts (9)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Five of Clubs from the draw pile.

# The top card on the discard pile is: Queen of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6), Jack of Diamonds (7), Two of Diamonds (8), King of Hearts (9), Five of Clubs (10)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Two of Spades from the draw pile.

# The top card on the discard pile is: Queen of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6), Jack of Diamonds (7), Two of Diamonds (8), King of Hearts (9), Five of Clubs (10), Two of Spades (11)

# If you can/do not wish to play, type 'pass' to pass.
# 11

# You play your Two of Spades.

# The dealer plays their King of Spades.

# The top card on the discard pile is: King of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6), Jack of Diamonds (7), Two of Diamonds (8), King of Hearts (9), Five of Clubs (10)

# If you can/do not wish to play, type 'pass' to pass.
# 9

# You play your King of Hearts.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their King of Clubs.

# The top card on the discard pile is: King of Clubs.
# What card would you like to play?  Your hand contains:
# Nine of Clubs (1), Six of Clubs (2), Nine of Hearts (3), Ace of Hearts (4), Ace of Clubs (5), Three of Hearts (6), Jack of Diamonds (7), Two of Diamonds (8), Five of Clubs (9)

# If you can/do not wish to play, type 'pass' to pass.
# 1

# You play your Nine of Clubs.

# The dealer plays their Jack of Clubs.

# The top card on the discard pile is: Jack of Clubs.
# What card would you like to play?  Your hand contains:
# Six of Clubs (1), Nine of Hearts (2), Ace of Hearts (3), Ace of Clubs (4), Three of Hearts (5), Jack of Diamonds (6), Two of Diamonds (7), Five of Clubs (8)

# If you can/do not wish to play, type 'pass' to pass.
# 4

# You play your Ace of Clubs.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Eight of Diamonds.

# The dealer played an Eight, and decided to change the suit to Spades.

# The top card on the discard pile is: Eight of Spades.
# What card would you like to play?  Your hand contains:
# Six of Clubs (1), Nine of Hearts (2), Ace of Hearts (3), Three of Hearts (4), Jack of Diamonds (5), Two of Diamonds (6), Five of Clubs (7)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Ten of Hearts from the draw pile.

# The top card on the discard pile is: Eight of Spades.
# What card would you like to play?  Your hand contains:
# Six of Clubs (1), Nine of Hearts (2), Ace of Hearts (3), Three of Hearts (4), Jack of Diamonds (5), Two of Diamonds (6), Five of Clubs (7), Ten of Hearts (8)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Jack of Hearts from the draw pile.

# The top card on the discard pile is: Eight of Spades.
# What card would you like to play?  Your hand contains:
# Six of Clubs (1), Nine of Hearts (2), Ace of Hearts (3), Three of Hearts (4), Jack of Diamonds (5), Two of Diamonds (6), Five of Clubs (7), Ten of Hearts (8), Jack of Hearts (9)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw King of Diamonds from the draw pile.

# The top card on the discard pile is: Eight of Spades.
# What card would you like to play?  Your hand contains:
# Six of Clubs (1), Nine of Hearts (2), Ace of Hearts (3), Three of Hearts (4), Jack of Diamonds (5), Two of Diamonds (6), Five of Clubs (7), Ten of Hearts (8), Jack of Hearts (9), King of Diamonds (10)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Ace of Spades from the draw pile.

# The top card on the discard pile is: Eight of Spades.
# What card would you like to play?  Your hand contains:
# Six of Clubs (1), Nine of Hearts (2), Ace of Hearts (3), Three of Hearts (4), Jack of Diamonds (5), Two of Diamonds (6), Five of Clubs (7), Ten of Hearts (8), Jack of Hearts (9), King of Diamonds (10), Ace of Spades (11)

# If you can/do not wish to play, type 'pass' to pass.
# 11

# You play your Ace of Spades.

# The dealer plays their Six of Spades.

# The top card on the discard pile is: Six of Spades.
# What card would you like to play?  Your hand contains:
# Six of Clubs (1), Nine of Hearts (2), Ace of Hearts (3), Three of Hearts (4), Jack of Diamonds (5), Two of Diamonds (6), Five of Clubs (7), Ten of Hearts (8), Jack of Hearts (9), King of Diamonds (10)

# If you can/do not wish to play, type 'pass' to pass.
# 1

# You play your Six of Clubs.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Six of Hearts.

# The top card on the discard pile is: Six of Hearts.
# What card would you like to play?  Your hand contains:
# Nine of Hearts (1), Ace of Hearts (2), Three of Hearts (3), Jack of Diamonds (4), Two of Diamonds (5), Five of Clubs (6), Ten of Hearts (7), Jack of Hearts (8), King of Diamonds (9)

# If you can/do not wish to play, type 'pass' to pass.
# 2

# You play your Ace of Hearts.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Two of Hearts.

# The top card on the discard pile is: Two of Hearts.
# What card would you like to play?  Your hand contains:
# Nine of Hearts (1), Three of Hearts (2), Jack of Diamonds (3), Two of Diamonds (4), Five of Clubs (5), Ten of Hearts (6), Jack of Hearts (7), King of Diamonds (8)

# If you can/do not wish to play, type 'pass' to pass.
# 4

# You play your Two of Diamonds.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Eight of Clubs.

# The draw pile is empty, and no plays can be made.
# The discard pile has been reshuffled into the draw pile.

# The top card on the discard pile is: Ace of Clubs.
# What card would you like to play?  Your hand contains:
# Nine of Hearts (1), Three of Hearts (2), Jack of Diamonds (3), Five of Clubs (4), Ten of Hearts (5), Jack of Hearts (6), King of Diamonds (7)

# If you can/do not wish to play, type 'pass' to pass.
# 4

# You play your Five of Clubs.

# The dealer plays their Five of Spades.

# The top card on the discard pile is: Five of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Hearts (1), Three of Hearts (2), Jack of Diamonds (3), Ten of Hearts (4), Jack of Hearts (5), King of Diamonds (6)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Eight of Hearts from the draw pile.

# The top card on the discard pile is: Five of Spades.
# What card would you like to play?  Your hand contains:
# Nine of Hearts (1), Three of Hearts (2), Jack of Diamonds (3), Ten of Hearts (4), Jack of Hearts (5), King of Diamonds (6), Eight of Hearts (7)

# If you can/do not wish to play, type 'pass' to pass.
# 7

# You play your Eight of Hearts.

# You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades.
# Hearts

# You chose to change the playable suit to: Hearts.

# The top card on the discard pile is: Eight of Hearts.

# The dealer plays their Five of Hearts.

# The top card on the discard pile is: Five of Hearts.
# What card would you like to play?  Your hand contains:
# Nine of Hearts (1), Three of Hearts (2), Jack of Diamonds (3), Ten of Hearts (4), Jack of Hearts (5), King of Diamonds (6)

# If you can/do not wish to play, type 'pass' to pass.
# 1

# You play your Nine of Hearts.

# The dealer plays their Nine of Spades.

# The top card on the discard pile is: Nine of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Jack of Diamonds (2), Ten of Hearts (3), Jack of Hearts (4), King of Diamonds (5)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Six of Diamonds from the draw pile.

# The top card on the discard pile is: Nine of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Jack of Diamonds (2), Ten of Hearts (3), Jack of Hearts (4), King of Diamonds (5), Six of Diamonds (6)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Seven of Clubs from the draw pile.

# The top card on the discard pile is: Nine of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Jack of Diamonds (2), Ten of Hearts (3), Jack of Hearts (4), King of Diamonds (5), Six of Diamonds (6), Seven of Clubs (7)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Nine of Diamonds from the draw pile.

# The top card on the discard pile is: Nine of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Jack of Diamonds (2), Ten of Hearts (3), Jack of Hearts (4), King of Diamonds (5), Six of Diamonds (6), Seven of Clubs (7), Nine of Diamonds (8)

# If you can/do not wish to play, type 'pass' to pass.
# 8

# You play your Nine of Diamonds.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Eight of Clubs.

# The dealer played an Eight, and decided to change the suit to Clubs.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Jack of Diamonds (2), Ten of Hearts (3), Jack of Hearts (4), King of Diamonds (5), Six of Diamonds (6), Seven of Clubs (7)

# If you can/do not wish to play, type 'pass' to pass.
# 7

# You play your Seven of Clubs.

# The dealer plays their King of Clubs.

# The top card on the discard pile is: King of Clubs.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Jack of Diamonds (2), Ten of Hearts (3), Jack of Hearts (4), King of Diamonds (5), Six of Diamonds (6)

# If you can/do not wish to play, type 'pass' to pass.
# 5

# You play your King of Diamonds.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Queen of Diamonds.

# The top card on the discard pile is: Queen of Diamonds.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Jack of Diamonds (2), Ten of Hearts (3), Jack of Hearts (4), Six of Diamonds (5)

# If you can/do not wish to play, type 'pass' to pass.
# 2

# You play your Jack of Diamonds.

# The dealer plays their Jack of Spades.

# The top card on the discard pile is: Jack of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Ten of Hearts (2), Jack of Hearts (3), Six of Diamonds (4)

# If you can/do not wish to play, type 'pass' to pass.
# 3

# You play your Jack of Hearts.

# The dealer plays their Queen of Hearts.

# The top card on the discard pile is: Queen of Hearts.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Ten of Hearts (2), Six of Diamonds (3)

# If you can/do not wish to play, type 'pass' to pass.
# 2

# You play your Ten of Hearts.

# The dealer plays their Ten of Spades.

# The top card on the discard pile is: Ten of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Six of Diamonds (2)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Six of Clubs from the draw pile.

# The top card on the discard pile is: Ten of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Six of Diamonds (2), Six of Clubs (3)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Queen of Spades from the draw pile.

# The top card on the discard pile is: Ten of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Six of Diamonds (2), Six of Clubs (3), Queen of Spades (4)

# If you can/do not wish to play, type 'pass' to pass.
# 4

# You play your Queen of Spades.

# The dealer plays their Three of Spades.

# The top card on the discard pile is: Three of Spades.
# What card would you like to play?  Your hand contains:
# Three of Hearts (1), Six of Diamonds (2), Six of Clubs (3)

# If you can/do not wish to play, type 'pass' to pass.
# 1

# You play your Three of Hearts.

# The dealer plays their Three of Clubs.

# The top card on the discard pile is: Three of Clubs.
# What card would you like to play?  Your hand contains:
# Six of Diamonds (1), Six of Clubs (2)

# If you can/do not wish to play, type 'pass' to pass.
# 2

# You play your Six of Clubs.

# The dealer plays their Ten of Clubs.

# The top card on the discard pile is: Ten of Clubs.
# What card would you like to play?  Your hand contains:
# Six of Diamonds (1)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Seven of Diamonds from the draw pile.

# The top card on the discard pile is: Ten of Clubs.
# What card would you like to play?  Your hand contains:
# Six of Diamonds (1), Seven of Diamonds (2)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Eight of Spades from the draw pile.

# The top card on the discard pile is: Ten of Clubs.
# What card would you like to play?  Your hand contains:
# Six of Diamonds (1), Seven of Diamonds (2), Eight of Spades (3)

# If you can/do not wish to play, type 'pass' to pass.
# 3

# You play your Eight of Spades.

# You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades.
# Diamonds

# You chose to change the playable suit to: Diamonds.

# The top card on the discard pile is: Eight of Diamonds.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Ten of Diamonds.

# The top card on the discard pile is: Ten of Diamonds.
# What card would you like to play?  Your hand contains:
# Six of Diamonds (1), Seven of Diamonds (2)

# If you can/do not wish to play, type 'pass' to pass.
# 1

# You play your Six of Diamonds.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer plays their Eight of Diamonds.

# The dealer played an Eight, and decided to change the suit to Clubs.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Ace of Hearts from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw King of Spades from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Six of Spades from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Four of Hearts from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Five of Diamonds from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw King of Hearts from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Two of Spades from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Ace of Diamonds from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Two of Diamonds from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Two of Hearts from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Jack of Clubs from the draw pile.

# The top card on the discard pile is: Eight of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11), Jack of Clubs (12)

# If you can/do not wish to play, type 'pass' to pass.
# 12

# You play your Jack of Clubs.

# The dealer plays their Queen of Clubs.

# The top card on the discard pile is: Queen of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11)

# If you can/do not wish to play, type 'pass' to pass.
# pas

# Error: was expecting 'pass' or an integer between 1 and 11.

# The top card on the discard pile is: Queen of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Six of Hearts from the draw pile.

# The top card on the discard pile is: Queen of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11), Six of Hearts (12)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Four of Diamonds from the draw pile.

# The top card on the discard pile is: Queen of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11), Six of Hearts (12), Four of Diamonds (13)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Ace of Spades from the draw pile.

# The top card on the discard pile is: Queen of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11), Six of Hearts (12), Four of Diamonds (13), Ace of Spades (14)

# If you can/do not wish to play, type 'pass' to pass.
# pass

# You draw Nine of Clubs from the draw pile.

# The top card on the discard pile is: Queen of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11), Six of Hearts (12), Four of Diamonds (13), Ace of Spades (14), Nine of Clubs (15)

# If you can/do not wish to play, type 'pass' to pass.
# 15

# You play your Nine of Clubs.

# The dealer plays their Four of Clubs.

# The top card on the discard pile is: Four of Clubs.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11), Six of Hearts (12), Four of Diamonds (13), Ace of Spades (14)

# If you can/do not wish to play, type 'pass' to pass.
# 13

# You play your Four of Diamonds.

# The dealer plays their Four of Spades.

# The top card on the discard pile is: Four of Spades.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Six of Spades (4), Four of Hearts (5), Five of Diamonds (6), King of Hearts (7), Two of Spades (8), Ace of Diamonds (9), Two of Diamonds (10), Two of Hearts (11), Six of Hearts (12), Ace of Spades (13)

# If you can/do not wish to play, type 'pass' to pass.
# 4

# You play your Six of Spades.

# The dealer plays their Seven of Spades.

# The top card on the discard pile is: Seven of Spades.
# What card would you like to play?  Your hand contains:
# Seven of Diamonds (1), Ace of Hearts (2), King of Spades (3), Four of Hearts (4), Five of Diamonds (5), King of Hearts (6), Two of Spades (7), Ace of Diamonds (8), Two of Diamonds (9), Two of Hearts (10), Six of Hearts (11), Ace of Spades (12)

# If you can/do not wish to play, type 'pass' to pass.
# 12

# You play your Ace of Spades.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card, and draws from the draw pile.

# The dealer was unable to play a card.

# The draw pile is empty, and no plays can be made.
# The discard pile has been reshuffled into the draw pile.

# You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades.
