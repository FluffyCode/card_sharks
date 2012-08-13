class GoFishHandMatch
	def find_matching_set(player)
		# look for matching sets
		ranks_to_search_for = []
		is_set_of_four = 0
		player.hand.each do |card|
			ranks_to_search_for << tell_card_rank(card)
		end

		ranks_to_search_for.each do |rank|
			@cards_to_score = player.hand.find_all { |card| card.include?(rank) }
			if @cards_to_score.length == 4
				is_set_of_four = 1
				@last_rank_called = rank
				break
			end
		end

		# score with the matching sets
		if is_set_of_four == 1
			@cards_to_score.each do |card_a|
				player.hand.each do |card_b|
					player.hand.delete(card_b) if card_b == card_a
				end
			end

			until @cards_to_score.length == 0
				player.add_to_score_pool(@cards_to_score.delete(@cards_to_score[0]))
			end
			
			# tell the player (or dealer) what they scored with
			if player == @player
				puts "You score with a set of #{@last_rank_called}."
			else
				puts "The dealer scores with a set of #{@last_rank_called}."
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
