class GoFishHandMatch
	def strip_suit(card)
		card.to_s.gsub(/( of Clubs)/, "").gsub(/( of Diamonds)/, "").gsub(/( of Hearts)/, "").gsub(/( of Spades)/, "")
	end

	def count_these(this_rank, hand)
		counter = 0

		hand.each do |card|
			if card.include?(this_rank)
				counter += 1
			end
		end

		return counter
	end

	def find_set_of_four(this_rank, player)
		if count_these(this_rank, player.hand) == 4
			add_set_to_score_pool(this_rank, player)
		end
	end

	def add_set_to_score_pool(this_rank, player)
		x = 0

		until player.hand[x] == nil
			if player.hand[x].include?(this_rank)
				player.add_to_score_pool(player.hand.delete(player.hand[x]))
			else
				x += 1
			end
		end
	end

	def transfer_card(this_rank, giver, taker)
		x = 0

		until giver.hand[x] == nil
			if giver.hand[x].include?(this_rank)
				if taker == @dealer
					puts "You pass the dealer your #{giver.hand[x]}."
				else
					puts "The dealer passes you their #{giver.hand[x]}."
				end
				taker.add_to_score_pool(giver.hand.delete(giver.hand[x]))
			else
				x += 1
			end
		end
	end
end
