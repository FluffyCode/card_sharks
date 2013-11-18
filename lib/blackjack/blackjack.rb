# blackjack.rb version 3.3

require_relative "../master/deck"
require_relative "../master/player"
require_relative "../master/dealer"
require_relative "blackjack_value"

# Notes on progress / current problems:
	# Rework hit_or_stay loop - currently, only "stay" is recognized.  If a player inputs anything other than "stay",
	# it is considered a hit - problem, even if "stay" is intended, but mistyped.



class Blackjack
	def initialize
		@player = Player.new
		@dealer = Dealer.new
	end

	def round_of_blackjack
		@player_bid = @player.make_bid
		@player_credits = @player.credits

		# Reset the hands of the player and dealer, ensuring an empty array each round
		@player.wipe_hand
		@dealer.wipe_hand

		# New, shuffled deck each round
		@deck = Deck.new
		@deck.shuffle!

		# Deal two cards to player ("physically" removing them from @deck)
		2.times { @player.deal(@deck.remove_top_card) }
		# Then ditto for the dealer
		2.times { @dealer.deal(@deck.remove_top_card) }
		# Announce the second of the dealer's two cards
		puts "You have been dealt: #{@player.tell_hand}."
		puts "The dealer has been dealt two cards, and is showing #{@dealer.hand[1]}."

		def hit_or_stay
			def declare_hit_or_stay
				puts "Hit or stay?"
			end
			
			declare_hit_or_stay
			user_input = gets.chomp.downcase

			until user_input == "stay"
				if user_input == "hit"
					@player.deal(@deck.remove_top_card)
					puts "Your hand contains #{@player.tell_hand}."

					if evaluate_hand_score(@player.hand) == 21
						# Break player out of until-loop when they hit towards 21
						puts "Your hand's score is 21."
						break
					elsif evaluate_hand_score(@player.hand) > 21
						puts "You busted with #{evaluate_hand_score(@player.hand)}."
						end_round("lose")
					end

					declare_hit_or_stay
					user_input = gets.chomp.downcase
				
				else
					puts "Input error: was expecting 'hit' or 'stay'"
					user_input = gets.chomp.downcase
				end
			end
		end

	  def evaluate_hand_score(hand)
	  	hand_score = (BlackjackValue.new(hand)).value
	  end

		def blackjack_check(hand)
			is_a_blackjack = (BlackjackValue.new(hand)).is_blackjack
		end

		def end_round(conditional)
			puts "This round, the dealer's hand contained: #{@dealer.tell_hand}."
			if conditional == "win"
				# Double the player's bid and add that number to their credits pool.
				puts "Winning doubled your bid of #{@player_bid}. You had #{@player.credits} credits, and now have #{@player.credits + (@player_bid * 2)} credits."
				@player.update_credits(@player_bid * 2)
				play_a_game(0)
			elsif conditional == "lose"
				# Deduct the player's bid from their credit pool.
				puts "You lost your bid of #{@player_bid}. You had #{@player.credits} credits, and are down to #{@player.credits - (@player_bid)} credits."
				@player.update_credits(@player_bid * -1)
				play_a_game(0)
			else
				# On a push (tie), do nothing to the player's credit pool.
				puts "This round was a push. Your bid has been returned - you have #{@player.credits} credits."
				play_a_game(0)
			end
		end

		# First, the player's turn:
		if evaluate_hand_score(@player.hand) == 21
			# If initial deal == 21, skip hit_or_stay
		else
			# Go into hit_or_stay if initial deal != 21
			hit_or_stay
		end

		# Save score as an integer in players_score
		players_score = evaluate_hand_score(@player.hand)
		# Determine if the player's hand is a blackjack
		player_has_blackjack = blackjack_check(@player.hand)

		#Dealer's turn
		dealers_score = evaluate_hand_score(@dealer.hand)
		dealer_has_blackjack = blackjack_check(@dealer.hand)
		# Until the value of dealers_hand > 15, they hit
		until dealers_score > 15
			was_dealt = @deck.deck(0)
			@dealer.deal(@deck.remove_top_card)
			puts "The dealer adds a #{was_dealt} to their hand."
			dealers_score = evaluate_hand_score(@dealer.hand)
		end
		# The dealer busts if over 21
		if dealers_score > 21
			puts "The dealer busts with #{dealers_score}."
			end_round("win")
		end

		# Final scoring
		# First, does anyone have a Blackjack?
		if player_has_blackjack == true || dealer_has_blackjack == true
			if player_has_blackjack == true && dealer_has_blackjack == false
				puts "Your Blackjack trumps the dealer's #{dealers_score}."
				end_round("win")
			elsif player_has_blackjack == false && dealer_has_blackjack == true
				puts "The dealer's Blackjack trumps your #{players_score}."
				end_round("lose")
			elsif player_has_blackjack == true && dealer_has_blackjack == true
				puts "Both you and the dealer have a Blackjack."
				end_round("push")
			end

		# Second, if no Blackjacks are in anyone's hand:
		elsif players_score > dealers_score
			puts "Your #{players_score} whomps the dealer's meager #{dealers_score}."
			end_round("win")
		elsif dealers_score > players_score
			puts "The dealer's #{dealers_score} eats your #{players_score} for breakfast."
			end_round("lose")
		else
			end_round("push")
		end
	end
end

def play_a_game(x)
	puts "Would you like to play a round of blackjack? (y/n)"
	user_input = gets.chomp.downcase

	if user_input == "y"
		if x == 1
			Blackjack.new.round_of_blackjack
		else
			round_of_blackjack
		end
	elsif user_input == "n"
		puts "Alrighty then, another time!"
		exit 0
	else
		puts "Input error: was expecting y/n"
		play_a_game(x)
	end
end

play_a_game(1)
