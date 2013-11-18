require_relative "../lib/master/card"
require_relative "../lib/add_a_card/add_a_card_value"

describe AddACardValue do
  let(:eval_class) { AddACardValue.new }
  let(:hand) { [] }

  it "evaluates [Ace + 8] = 18" do
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Hearts", "Eight")

    eval_class.cards(hand)

    eval_class.value.should == 18
  end

end
