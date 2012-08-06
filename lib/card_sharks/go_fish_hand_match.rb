class GoFishHandMatch
	def initialize(hand)
		@hand = hand
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

	def find_set_of_four(this_rank)
		if count_these(this_rank) == 4
			true
		else
			false
		end
	end

	def transfer_card(this_rank, giver, taker)
		giver.each do |card|
			if card.include?(this_rank)
				taker << giver.delete(card)
				# Recursion, here - start over if a transfer was made
				transfer_card(this_rank, giver, taker)
			end
		end
	end

end
