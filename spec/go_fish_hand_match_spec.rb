require "card_sharks/card"
require "card_sharks/go_fish_hand_match"
require "card_sharks/deck"
require "card_sharks/player"
require "card_sharks/dealer"

describe GoFishHandMatch do
	let(:hand) { [] }

	it "strips suits from the card, leaving only the rank" do
		result_one = GoFishHandMatch.new(hand).strip_suit(Card.new("Clubs", "Ace"))
		result_two = GoFishHandMatch.new(hand).strip_suit(Card.new("Diamonds", "Two"))
		result_three = GoFishHandMatch.new(hand).strip_suit(Card.new("Hearts", "Three"))
		result_four = GoFishHandMatch.new(hand).strip_suit(Card.new("Spades", "Four"))

		hand << result_one
		hand << result_two
		hand << result_three
		hand << result_four

		hand.should == ["Ace", "Two", "Three", "Four"]
	end

	it "finds a specifically named card" do
		hand << Card.new("Hearts", "Seven")

		result = GoFishHandMatch.new(hand).find_this_card("Seven")
		result.should == true
	end

	it "finds a specifically named card in a hand" do
		hand << Card.new("Hearts", "Ace")
		hand << Card.new("Hearts", "Two")
		hand << Card.new("Hearts", "Three")
		hand << Card.new("Hearts", "Four")
		hand << Card.new("Hearts", "Five")
		hand << Card.new("Hearts", "Six")
		hand << Card.new("Hearts", "Seven")
		hand << Card.new("Hearts", "Eight")
		hand << Card.new("Hearts", "Nine")
		hand << Card.new("Hearts", "Ten")
		hand << Card.new("Hearts", "Jack")
		hand << Card.new("Hearts", "Queen")
		hand << Card.new("Hearts", "King")

		result = GoFishHandMatch.new(hand).find_this_card("Seven")
		result.should == true
	end

	it "finds all (2/4) of the named cards within a hand" do
		hand << Card.new("Hearts", "Seven")
		hand << Card.new("Spades", "Three")
		hand << Card.new("Spades", "Seven")

		result = GoFishHandMatch.new(hand).count_these("Seven")
		result.should == 2
	end

	it "finds all (3/4) of the named cards within a hand" do
		hand << Card.new("Hearts", "Seven")
		hand << Card.new("Spades", "Three")
		hand << Card.new("Spades", "Seven")
		hand << Card.new("Spades", "Ace")
		hand << Card.new("Clubs", "Four")
		hand << Card.new("Diamonds", "Eight")
		hand << Card.new("Diamonds", "Seven")
		hand << Card.new("Hearts", "Waffle")
		# What? It's lunch time, and I'm hungry...

		result = GoFishHandMatch.new(hand).count_these("Seven")
		result.should == 3
	end

	it "finds all (4/4) of the named cards within a hand" do
		some_deck = Deck.new
		some_deck.shuffle!
		52.times do
			hand << some_deck.remove_top_card
		end

		result = GoFishHandMatch.new(hand).count_these("Seven")
		result.should == 4
	end

	it "finds all 13 sets of 4 in a deck" do
		some_deck = Deck.new
		some_deck.shuffle!
		52.times do
			hand << some_deck.remove_top_card
		end

		res1 = GoFishHandMatch.new(hand).count_these("Ace")
		res2 = GoFishHandMatch.new(hand).count_these("Two")
		res3 = GoFishHandMatch.new(hand).count_these("Three")
		res4 = GoFishHandMatch.new(hand).count_these("Four")
		res5 = GoFishHandMatch.new(hand).count_these("Five")
		res6 = GoFishHandMatch.new(hand).count_these("Six")
		res7 = GoFishHandMatch.new(hand).count_these("Seven")
		res8 = GoFishHandMatch.new(hand).count_these("Eight")
		res9 = GoFishHandMatch.new(hand).count_these("Nine")
		res10 = GoFishHandMatch.new(hand).count_these("Ten")
		res11 = GoFishHandMatch.new(hand).count_these("Jack")
		res12 = GoFishHandMatch.new(hand).count_these("Queen")
		res13 = GoFishHandMatch.new(hand).count_these("King")

		result = (res1 + res2 + res3 + res4 + res5 + res6 + res7 + res8 + res9 + res10 + res11 + res12 + res13) / 4
		result.should == 13
	end

	it "finds all (1/4) cards of a rank in one player's hand, and gives them to the other player" do
		player1 = []
		player1 << Card.new("Clubs", "Seven")
		player1 << Card.new("Hearts", "Four")

		player2 = []

		GoFishHandMatch.new(hand).transfer_card("Seven", player1, player2)

		player2.should == [Card.new("Clubs", "Seven")]
	end

	it "finds all (2/4) cards of a rank in one player's hand, and gives them to the other player" do
		player1 = []
		player1 << Card.new("Clubs", "Seven")
		player1 << Card.new("Hearts", "Four")
		player1 << Card.new("Spades", "Seven")

		player2 = []

		GoFishHandMatch.new(hand).transfer_card("Seven", player1, player2)

		player2.should == [Card.new("Clubs", "Seven"), Card.new("Spades", "Seven")]				
	end

	it "finds all (3/4) cards of a rank in one player's hand, and gives them to the other player" do
		player1 = []
		player1 << Card.new("Clubs", "Seven")
		player1 << Card.new("Hearts", "Four")
		player1 << Card.new("Spades", "Seven")
		player1 << Card.new("Diamonds", "Seven")

		player2 = []

		GoFishHandMatch.new(hand).transfer_card("Seven", player1, player2)

		player2.should == [Card.new("Clubs", "Seven"), Card.new("Spades", "Seven"), Card.new("Diamonds", "Seven")]
	end


	it "finds all (4/4) cards of a rank in one player's hand, and gives them to the other player" do
		player1 = []
		player1 << Card.new("Clubs", "Seven")
		player1 << Card.new("Hearts", "Four")
		player1 << Card.new("Spades", "Seven")
		player1 << Card.new("Diamonds", "Seven")
		player1 << Card.new("Hearts", "Ten")
		player1 << Card.new("Diamonds", "Four")
		player1 << Card.new("Hearts", "Seven")

		player2 = []

		GoFishHandMatch.new(hand).transfer_card("Seven", player1, player2)

		player2.should == [Card.new("Clubs", "Seven"), Card.new("Spades", "Seven"), Card.new("Diamonds", "Seven"), Card.new("Hearts", "Seven")]
	end

	it "will not consider 1/4 ranks to be a full set" do
		hand << Card.new("Clubs", "Seven")

		result = GoFishHandMatch.new(hand).find_set_of_four("Seven")

		result.should == false
	end	

	it "will not consider 2/4 ranks to be a full set" do
		hand << Card.new("Clubs", "Seven")
		hand << Card.new("Diamonds", "Seven")

		result = GoFishHandMatch.new(hand).find_set_of_four("Seven")

		result.should == false
	end

	it "will not consider 3/4 ranks to be a full set" do
		hand << Card.new("Clubs", "Seven")
		hand << Card.new("Diamonds", "Seven")
		hand << Card.new("Hearts", "Seven")

		result = GoFishHandMatch.new(hand).find_set_of_four("Seven")

		result.should == false
	end

	it "will consider 4/4 ranks to be a full set" do
		hand << Card.new("Clubs", "Seven")
		hand << Card.new("Diamonds", "Seven")
		hand << Card.new("Hearts", "Seven")
		hand << Card.new("Spades", "Seven")

		result = GoFishHandMatch.new(hand).find_set_of_four("Seven")

		result.should == true
	end

end
