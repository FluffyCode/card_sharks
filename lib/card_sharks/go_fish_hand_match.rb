class GoFishHandMatch
	def initialize(hand, player, dealer)
		@hand = hand

		@player = player
		@dealer = dealer
	end

	def strip_suit(card)
		card.to_s.gsub(/( of Clubs)/, "").gsub(/( of Diamonds)/, "").gsub(/( of Hearts)/, "").gsub(/( of Spades)/, "")
	end

	def find_this_card(this_rank)
		presence_of_card = false

		@hand.each do |card|
			if card.include?(this_rank)
				presence_of_card = true
			end
		end

		return presence_of_card
	end

	def count_these(this_rank)
		counter = 0

		@hand.each do |card|
			if card.include?(this_rank)
				counter += 1
			end
		end

		return counter
	end

	def find_set_of_four(this_rank, player)
		if count_these(this_rank) == 4
			add_set_to_score_pool(this_rank, player)
		end
	end

	def add_set_to_score_pool(this_rank, player)
		player.hand.each do |card|
			if card.include?(this_rank)
				player.add_to_score_pool(player.hand.delete(card))
				# Recursion, here - start over if a card was added to the score pool
				add_set_to_score_pool(this_rank, player)
			end
		end
		check_for_end_game(@player, @dealer)
	end

	def transfer_card(this_rank, giver, taker)
		giver.hand.each do |card|
			if card.include?(this_rank)
				taker.hand << giver.hand.delete(card)
				puts "The dealer passes you their #{card}." if taker == @player
				puts "You pass the dealer your #{card}." if taker == @dealer

				find_set_of_four(this_rank, taker)

				# Recursion, here - start over if a transfer was made
				transfer_card(this_rank, giver, taker)
			end
		end
	end

end
