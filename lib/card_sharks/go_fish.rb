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

	# list of things working properly:
		# player can only ask for what they have at least 1 of
		# player gets another turn if they got what they ask for, or on a do_you_have_any or a go_fish

		# dealers_turn:
			# properly populates cards_to_chose_from
			# properly randomly selects something to ask for

		# find_matching_set

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

		# Current stage:
			# Incorporating find_matching_set into various places - basically, any time either player comes
			# into posession of a new card - to check to see if they have a full set of 4.

		# What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)
		# Five
		# The dealer did not have any: Five.
		# You fished a Four of Clubs from the pool.
		# The dealer asks for: Four.
		# You pass the dealer your Four of Clubs.
		# The dealer scores with a set of: Four.
		# The dealer got what they asked for, and gets another turn.
		# The dealer asks for: Four.
		# The dealer didn't get a Four, and goes fishing instead.
		# What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)
		# hand
		# Player hand: Ten of Clubs, Seven of Clubs, Jack of Clubs, Six of Spades, Seven of Hearts, King of Diamonds, Jack of Hearts, Ten of Diamonds, King of Spades, Seven of Diamonds, Eight of Diamonds, Ace of Clubs, Ace of Diamonds, Ace of Hearts, Ten of Hearts, Nine of Hearts, Six of Diamonds, Queen of Spades, King of Hearts, Five of Clubs, Queen of Clubs.
		# Dealer hand: Three of Diamonds, Two of Diamonds, Three of Spades, Four of Spades, Two of Clubs, Two of Spades, Four of Clubs, Nine of Diamonds.
		# What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)
			# ^ Here's a problem - all the fours were not removed from the dealer's hand during scoring
			# And again below:
		# Player hand: Three of Clubs, Nine of Clubs, Four of Diamonds, Two of Hearts, Eight of Clubs, Queen of Hearts, Queen of Spades, Queen of Clubs, Eight of Diamonds, Nine of Spades, Two of Diamonds, Four of Spades, Three of Hearts, King of Spades, King of Clubs, Five of Hearts.
		# Dealer hand: Six of Hearts, Five of Diamonds, Ace of Spades, Ace of Diamonds, Jack of Spades, Eight of Spades, Jack of Diamonds, Eight of Hearts, Ace of Clubs.
		# What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)
		# Eight
		# The dealer had a Eight; you add the Eight of Spades to your hand.
		# The dealer had a Eight; you add the Eight of Hearts to your hand.
		# You score with a set of: Eight.
		# You got what you asked for! You get another turn.
		# What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)
		# hand
		# Player hand: Three of Clubs, Nine of Clubs, Four of Diamonds, Two of Hearts, Queen of Hearts, Queen of Spades, Queen of Clubs, Nine of Spades, Two of Diamonds, Four of Spades, Three of Hearts, King of Spades, King of Clubs, Five of Hearts, Eight of Hearts.
		# Dealer hand: Six of Hearts, Five of Diamonds, Ace of Spades, Ace of Diamonds, Jack of Spades, Jack of Diamonds, Ace of Clubs.
		# What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)

		# go_fish.rb:134:in `block (2 levels) in find_matching_set': undefined method `include?' for nil:NilClass (NoMethodError)

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

		# Initial deal; 7 cards go to each player:
		7.times { @player.deal(@deck.remove_top_card) }
		7.times { @dealer.deal(@deck.remove_top_card) }

		# Ultimately, these two lines will be removed. Keep for now, while testing
		puts "Player hand: #{@player.tell_hand}."
		puts "Dealer hand: #{@dealer.tell_hand}."

		# def pass_cards_around(giver, taker, card)
			# temp placeholder for passing cards
		# end

		def tell_card_rank(card)
			card.to_s.gsub(/( of Clubs)/, "").gsub(/( of Diamonds)/, "").gsub(/( of Hearts)/, "").gsub(/( of Spades)/, "")
		end

		def check_for_game_over
			player_score = @player.score_pool.length / 4
			dealer_score = @dealer.score_pool.length / 4
			if player_score + dealer_score == 13
				puts "The game is over; you have #{player_score} sets, and the dealer has #{dealer_score} sets."
				if player_score > dealer_score
					puts "You won this round!"
				else
					puts "The dealer won this round."
				end
				play_a_game
			end
		end

		def find_matching_set(player)
			player.hand.each do |card_a|
				card_to_check_for = tell_card_rank(card_a)
				this_set = []

				player.hand.each do |card_b|
					if card_b.include?(card_to_check_for)
						this_set << card_b
					end
				end

				if this_set.length == 4
					player.hand.each do |card_c|
						player.add_to_score_pool(player.hand.delete(card_c)) if card_c.include?(card_to_check_for)
					end

					if player == @dealer
						puts "The dealer scores with a set of: #{card_to_check_for}."
					else
						puts "You score with a set of: #{card_to_check_for}."
					end
					find_matching_set(player)
				end
			end

			check_for_game_over 
		end

		def dealers_turn
			# dealer gets a pool of ranks to chose from:
			cards_to_chose_from = []
			# populate the choice-pool:
			@dealer.hand.each do |card|
				cards_to_chose_from << tell_card_rank(card)
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
					find_matching_set(@dealer) # find_matching_set here, after getting what they asked for
					got_what_they_asked_for = true
				end
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

			@player.hand.each do |card|
				can_ask_for = true if card.include?(requested_card)
			end

			if can_ask_for == true
				@dealer.hand.each do |card|
					if card.include?(requested_card)
						puts "The dealer had a #{requested_card}; you add the #{card} to your hand."
						@player.deal(@dealer.hand.delete(card))
						find_matching_set(@player) # find_matching_set here, after getting what they asked for
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

		def go_fish(card, player)
			if @deck.deck(0) != nil
				card_to_deal = @deck.remove_top_card
				player.deal(card_to_deal)
				
				# Tell the player what they got (but don't tell the player what the dealer got):
				if player == @player
					puts "You fished a #{card_to_deal} from the pool."
				end

				find_matching_set(player) # find_matching_set here, after being dealt a card from the "pool"

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
		find_matching_set(@player)
		find_matching_set(@dealer)

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
