class GoFishHandMatch
	def initialize(hand)
		@hand = hand
	end

	def strip_suit(card)
		card.to_s.gsub(/( of Clubs)/, "").gsub(/( of Diamonds)/, "").gsub(/( of Hearts)/, "").gsub(/( of Spades)/, "")
	end

	def find_this_card(find_me)
		presence_of_card = false

		@hand.each do |card|
			if card.include?(find_me)
				presence_of_card = true
			end
		end

		return presence_of_card
	end

end
