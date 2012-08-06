# go_fish.rb version 0.2

# initial setup for now; [important] stuff to remember for later:
	# players take turns asking for cards from one another
	# if a player has what the other asks for, the latter must turn over ALL cards of that RANK to the asking player
	# if a player gets what they ask for, they get another turn
	# if a player doesn't get what they ask for from another player, but get what they asked for from "going fishing,"
		# they get another turn - also, they must announce that they got what they asked for
	# a player CANNOT ask for something if THEY DO NOT have at least one of what they are asking for
	# when a player's hand contains all 4 suits of a RANK (King King King King), all of those cards are set aside
		# into a permanent score-pool for that player
	# player's score based on how many sets of 4 they have, via RANK (King King King King == a set)
	
# list of thing to do/fix:

require "card_sharks/deck"
require "card_sharks/player"
require "card_sharks/dealer"
require "card_sharks/go_fish_hand_match.rb"

class GoFish
	def initialize
		@player = Player.new
		@dealer = Dealer.new
	end

	def round_of_go_fish
		@player.wipe_hand
		@dealer.wipe_hand

		@deck = Deck.new
		@deck.shuffle!

		# Initial deal; 7 cards go to each player:
		7.times { @player.deal(@deck.remove_top_card) }
		7.times { @dealer.deal(@deck.remove_top_card) }

		# Ultimately, these two lines will be removed. Keep for now, while testing
		puts "Player hand: #{@player.tell_hand}."
		puts "Dealer hand: #{@dealer.tell_hand}."

		def tell_card_rank(card, hand)
			GoFishHandMatch.new(hand, @player, @dealer).strip_suit(card)
		end

		def game_end
			player_score = @player.score_pool.length / 4
			dealer_score = @dealer.score_pool.length / 4
			
			puts "The game is over; you have #{player_score} sets, and the dealer has #{dealer_score} sets."
		
			if player_score > dealer_score
				puts "You won this round!"
			else
				puts "The dealer won this round."
			end
		
			play_a_game
		end

		def dealers_turn
			# dealer gets a pool of ranks to chose from:
			cards_to_chose_from = []
			# populate the choice-pool:
			@dealer.hand.each do |card|
				cards_to_chose_from << GoFishHandMatch.new(@dealer.hand, @player, @dealer).strip_suit(card)
			end
			# randomly determine which card the dealer will ask for:
			random_card = cards_to_chose_from[rand(cards_to_chose_from.length)]
			# ask for it:
			puts "The dealer asks for: #{random_card}."

			got_what_they_asked_for = false
			hand_length_before_exchange = @dealer.hand.length
			GoFishHandMatch.new(@dealer.hand, @player, @dealer).transfer_card(random_card, @player, @dealer)
			hand_length_after_exchange = @dealer.hand.length
			got_what_they_asked_for = true if hand_length_after_exchange > hand_length_before_exchange
			GoFishHandMatch.new(@dealer.hand, @player, @dealer).find_set_of_four(random_card, @dealer) # May be incomplete: "random_card"

			if GoFishHandMatch.new(@dealer.hand, @player, @dealer).check_for_end_game(@player, @dealer) == true
				game_end
			end

			if got_what_they_asked_for == true
				ask_for(2)
			else
				puts "The dealer didn't get a #{random_card}, and goes fishing instead."
				go_fish(random_card, @dealer)
				ask_for(0)
			end
		end

		def player_turn(requested_card)
			got_what_they_asked_for = false
			can_ask_for = false

			can_ask_for = true if GoFishHandMatch.new(@player.hand, @player, @dealer).count_these(requested_card) > 0
			if can_ask_for == false
				puts "You cannot ask for that, as you do not have any."
				ask_for(0)
			end

			hand_length_before_exchange = @player.hand.length
			GoFishHandMatch.new(@player.hand, @player, @dealer).transfer_card(requested_card, @dealer, @player)
			hand_length_after_exchange = @player.hand.length
			got_what_they_asked_for = true if hand_length_after_exchange > hand_length_before_exchange
			GoFishHandMatch.new(@player.hand, @player, @dealer).find_set_of_four(requested_card, @player) # May be incomplete: "requested_card"

			if GoFishHandMatch.new(@player.hand, @player, @dealer).check_for_end_game(@player, @dealer) == true
				game_end
			end

			if got_what_they_asked_for == true
				ask_for(1)
			else
				puts "The dealer did not have any: #{requested_card}."
				go_fish(requested_card, @player)
				dealers_turn
			end
		end

		def go_fish(card, player)
			if @deck.deck(0) != nil
				card_to_deal = @deck.remove_top_card
				player.deal(card_to_deal)
				
				# Tell the player what they got (but don't tell the player what the dealer got):
				if player == @player
					puts "You fished a #{card_to_deal} from the pool."
				end

				# Name the rank of the card just dealt
				rank_dealt = GoFishHandMatch.new(player.hand, @player, @dealer).strip_suit(card_to_deal)
				# Find out if it's a full set of 4; if so, it gets put into the player's score pool
				GoFishHandMatch.new(@player.hand, @player, @dealer).find_set_of_four(rank_dealt, player)

				# The player gets another turn if they got what they asked for:
				if card_to_deal.include?(card)
					if player == @dealer
						ask_for(2)
					else
						ask_for(1)
					end
				end

			else
				# Don't deal a card if there are none left
				puts "There are no more fish in the pool."

				if player == @dealer
					dealers_turn
				else
					ask_for(0)
				end
			end
		end

		def ask_for(x)
			if x == 1
				puts "You got what you asked for! You get another turn."
			elsif x == 2
				puts "The dealer got what they asked for, and gets another turn."
				dealers_turn
			end

			puts "What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)"
			requested_card = gets.chomp
			if requested_card == "hand"
				puts
				puts "Player hand: #{@player.tell_hand}."
				# Remove the dealer after testing:
				puts "Dealer hand: #{@dealer.tell_hand}."
				puts
				ask_for(0)
			else
				player_turn(requested_card)
			end
		end

		# determine who goes first
		def who_goes_first
			# In the final version, uncomment the following line. Just for testing, player gets the first turn.
			# if rand(2) == 1
			if 1 == 1
				puts "You get the first turn."
				ask_for(0)
			else
				puts "The dealer gets the first turn."
				dealers_turn
			end
		end

		# First-time check for any matching sets:
		# For the player
		first_time_check = []
		@player.hand.length.times do |card|
			first_time_check << GoFishHandMatch.new(@player.hand, @player, @dealer).strip_suit(card)
		end
		first_time_check.each do |card|
			GoFishHandMatch.new(@player.hand, @player, @dealer).find_set_of_four(card, @player)
		end

		# For the dealer
		first_time_check = []
		@dealer.hand.length.times do |card|
			first_time_check << GoFishHandMatch.new(@dealer.hand, @player, @dealer).strip_suit(card)
		end
		first_time_check.each do |card|
			GoFishHandMatch.new(@dealer.hand, @player, @dealer).find_set_of_four(card, @dealer)
		end

		who_goes_first
	end
end

def play_a_game
	puts "Would you like to play a game of Go Fish?"
	if gets.chomp.downcase == "yes"
		GoFish.new.round_of_go_fish
	else 
		puts "Alrighty then, another time!"
		exit 0
	end
end

play_a_game
