# go_fish.rb version 0.1

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

	# list of things working properly:
		# player can only ask for what they have at least 1 of
		# player gets another turn if they got what they ask for, or on a do_you_have_any or a go_fish

		# dealers_turn:
			# properly populates cards_to_chose_from
			# properly randomly selects something to ask for

	# list of thing to do/fix:
		# Would you like to play a game of Go Fish?
		# yes
		# Player hand: Two of Clubs, Nine of Clubs, Eight of Spades, Six of Spades, Eight of Clubs, King of Clubs, King of Spades.
		# Dealer hand: Two of Hearts, Two of Diamonds, Seven of Spades, Four of Clubs, Six of Diamonds, Five of Spades, Four of Spades.
		# You get the first turn.
		# What rank do you want to ask your opponent for?
		# Two
		# The dealer had a Two; you add the Two of Hearts to your hand.
		# You got what you asked for! You get another turn.
		# What rank do you want to ask your opponent for?
		# Two
		# The dealer had a Two; you add the Two of Diamonds to your hand.
		# You got what you asked for! You get another turn.
		# What rank do you want to ask your opponent for?
			# Don't know why this is acting up - I just fixed this in a way that it should have read:
				# Two
				# The dealer had a Two; you add the Two of Hearts to your hand.
				# The dealer had a Two; you add the Two of Diamonds to your hand.
				# You got what you asked for! You get another turn.
				# What rank do you want to ask your opponent for?

		# go_fish now incorporated into do_you_have_any and dealers_turn; however:
			# puts "A #{card_to_deal} is fished from the pool."
				# Need to do something about that. Tell the player what they got, but don't tell the player what the dealer got.

require "card_sharks/deck"
require "card_sharks/player"
require "card_sharks/dealer"

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

		# Initial deal; 7 cards go to each player.
		7.times { @player.deal(@deck.remove_top_card) }
		7.times { @dealer.deal(@deck.remove_top_card) }

		# Ultimately, these two lines will be removed. Keep for now, while testing
		puts "Player hand: #{@player.tell_hand}."
		puts "Dealer hand: #{@dealer.tell_hand}."

		# def pass_cards_around(giver, taker, card)
			# temp placeholder for passing cards
		# end

		def dealers_turn
			# dealer gets a pool of ranks to chose from:
			cards_to_chose_from = []
			# populate the choice-pool:
			@dealer.hand.each do |card|
				# card != String, via is_a?
				cards_to_chose_from << card.to_s.gsub(/( of Clubs)/, "").gsub(/( of Diamonds)/, "").gsub(/( of Hearts)/, "").gsub(/( of Spades)/, "")
			end
			# randomly determine which card the dealer will ask for:
			random_card = cards_to_chose_from[rand(cards_to_chose_from.length)]

			# ask for it:
			puts "The dealer asks for: #{random_card}."

			got_what_they_asked_for = false
			@player.hand.each do |card|
				if card.include?(random_card)
					@dealer.deal(@player.hand.delete(card))
					puts "You pass the dealer your #{card}."
					got_what_they_asked_for = true
				end
			end

			if got_what_they_asked_for == true
				puts "The dealer got what they asked for, and gets another turn."
				dealers_turn
			else
				puts "The dealer didn't get a #{random_card}, and goes fishing instead."
				go_fish(random_card, @dealer)
				ask_for(0)
			end
		end

		def go_fish(card, player)
			card_to_deal = @deck.remove_top_card
			puts "A #{card_to_deal} is fished from the pool."
			player.deal(card_to_deal)

			# The player gets another turn if they got what they asked for:
			if card_to_deal.include?(card)
				if player == @dealer
					dealers_turn
				else
					ask_for(0)
				end
			end
		end

		def player_turn(requested_card)
			got_what_they_asked_for = false
			can_ask_for = false

			@player.hand.each do |card|
				can_ask_for = true if card.include?(requested_card)
			end

			if can_ask_for == true
				@dealer.hand.each do |card|
					if card.include?(requested_card)
						puts "The dealer had a #{requested_card}; you add the #{card} to your hand."
						@player.deal(@dealer.hand.delete(card))
						got_what_they_asked_for = true
					end
				end
			else
				puts "You cannot ask for that, as you do not have any."
				ask_for(0)
			end

			if got_what_they_asked_for == true
				ask_for(1)
			else
				puts "The dealer did not have any: #{requested_card}."
				go_fish(requested_card, @player)
				dealers_turn
			end
		end

		def ask_for(x)
			if x == 1
				puts "You got what you asked for! You get another turn."
			end
			puts "What rank do you want to ask your opponent for?"
			requested_card = gets.chomp
			player_turn(requested_card)
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
