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
		# player gets another turn if they got what they ask for, or on a do_you_have_any or a go_fish

	# list of things half-working:
		# they player cannot ask for something they don't have - but the program is not incrementing through hands properly -
			# either the player's or the dealer's - so it may not find something that they DO have.

	# list of thing to do/fix:
		# While testing the .gsub in dealers_turn:
			# Player hand: Eight of Diamonds, Ace of Diamonds, Three of Clubs, Nine of Clubs, Five of Spades, Queen of Spades, Ten of Clubs.
			# Dealer hand: Ace of Clubs, Jack of Diamonds, King of Diamonds, Ace of Spades, Queen of Hearts, Nine of Diamonds, Six of Diamonds.
			# You get the first turn.
			# What rank do you want to ask your opponent for?
			# Ace
			# The dealer had a Ace; you add the Ace of Clubs to your hand.
			# What rank do you want to ask your opponent for?
				# The dealer had two Aces - Clubs and Spades - but the player was not given both, only one.
				# [Part of the] problem is, the program calls ask_for befoing finishing going through the entire hand
				# This may also have to do with why the program isn't finding a rank sometimes:
			# Ace
			# The dealer does not have any Aces. You go fish, instead.
			# You fish a Jack of Hearts from the pool.
				# The program isn't going far enough through the hand to find the rank.

		# Also, the .gsub doesn't quite work:
			# go_fish.rb:92:in `block in dealers_turn': undefined method `gsub' for Jack of Diamonds:Card (NoMethodError)

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

		def dealers_turn
			# dealer gets a pool of ranks to chose from:
			cards_to_chose_from = []
			# populate the choice-pool:
			@dealer.hand.each do |card|
				# .gsub(/( of Spades|| of Diamonds|| of Hearts|| of Clubs)/, "")
					# ...is not being recognized. Trying to be too crafty by putting or's into a gsub?
				# .gsub(/( of Clubs),( of Diamonds),( of Hearts),( of Spades)/, "")
					# Does not work either, after a test.

				# Chaining .gsubs seems to work, instead:
				card.gsub(/( of Clubs)/, "").gsub(/( of Diamonds)/, "").gsub(/( of Hearts)/, "").gsub(/( of Spades)/, "")
			end

			# randomly determine which card the dealer will ask for:
			random_card = rand(cards_to_chose_from.length)

			# ask for it:
			# Remove the following line after testing:
			puts "The dealer can chose: #{cards_to_chose_from}."
			puts "The dealer asks for your #{random_card.ranks}s."
		end

		def go_fish(card)
			card_to_deal = @deck.remove_top_card
			puts "You fish a #{card_to_deal} from the pool."
			@player.deal(card_to_deal)

			# The player gets another turn if they got what they asked for:
			if card_to_deal.include?(card)
				puts "You got what you asked for! You get another turn."
				ask_for
			else
				dealers_turn
			end
		end

		def do_you_have_any(requested_card)
			got_what_they_asked_for = false
			can_ask_for = false

			# if they player doesn't have at least one of what they are asking for, they can't ask for it:
			@player.hand.each do |card|
				if card.include?(requested_card)
					can_ask_for = true
				end
					
				if can_ask_for == true
					@dealer.hand.each do |card|
						if card.include?(requested_card)
							@player.deal(@dealer.hand.delete(card))
							puts "The dealer had a #{requested_card}; you add the #{card} to your hand."
							puts "Updated dealer hand: #{@dealer.tell_hand}."
							got_what_they_asked_for = true
						end
					end
				else
					puts "You cannot ask for a #{requested_card}, as you do not have any."
					ask_for
				end
			end

			if got_what_they_asked_for == true
				puts "You got what you asked for! You get to go again."
				ask_for
			else
				puts "The dealer did not have any."
				go_fish(requested_card)
			end
		end

		def ask_for
			puts "What rank do you want to ask your opponent for?"
			requested_card = gets.chomp
			do_you_have_any(requested_card)
		end

		# determine who goes first
		def who_goes_first
			# In the final version, uncomment the following line. Just for testing, player gets the first turn.
			# if rand(2) == 1
			if 1 == 1	
				puts "You get the first turn."
				ask_for
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
