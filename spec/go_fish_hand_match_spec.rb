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

end
