require_relative "../lib/master/card"
require_relative "../lib/blackjack/blackjack_value"
require_relative "../lib/master/deck"

describe BlackjackValue do
  let(:hand) { [] }

  it "calculates the value of an empty hand as 0." do
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 0
  end

  it "calcuates the value of a single card." do
    hand << Card.new("Hearts", "Three")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 3
  end

  it "calcuates the value of a hand that busts." do
    hand << Card.new("Clubs", "Queen")
    hand << Card.new("Hearts", "Seven")
    hand << Card.new("Clubs", "Eight")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 25
  end

  it "tests soft Aces (11)." do
    hand << Card.new("Hearts", "Ten")
    hand << Card.new("Clubs", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  # tests with a single ace
  it "tests hard Aces (1) - does not bust, < 21." do
    hand << Card.new("Hearts", "Ten")
    hand << Card.new("Hearts", "Eight")
    hand << Card.new("Clubs", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 19
  end

  it "tests hard Aces (1) - results in 21." do
    hand << Card.new("Hearts", "Ten")
    hand << Card.new("Spades", "Queen")
    hand << Card.new("Diamonds", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  it "tests hard Aces (1) - reduces a single Ace, busts." do
    hand << Card.new("Hearts", "Ten")
    hand << Card.new("Spades", "Queen")
    hand << Card.new("Spades", "Two")
    hand << Card.new("Diamonds", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 23
  end

  # tests with two aces
  it "tests two Aces - only reduces one of the Aces." do
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Hearts", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 12
  end

  it "tests two Aces - only reduces one, and == 21." do
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Six")
    hand << Card.new("Spades", "Three")
    hand << Card.new("Clubs", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  it "tests two Aces - reduces both, < 21." do
    hand << Card.new("Hearts", "Ten")
    hand << Card.new("Hearts", "Eight")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 20
  end

  it "tests two Aces - reduces both, == 21." do
    hand << Card.new("Hearts", "Ten")
    hand << Card.new("Hearts", "Nine")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  it "tests two Aces - reduces both, busts." do
    hand << Card.new("Hearts", "Ten")
    hand << Card.new("Hearts", "Queen")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 22
  end

  # tests with three aces
  it "tests three Aces - reduces 2." do
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 13
  end

  it "tests three Aces - reduces 2, < 21." do
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Seven")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 20
  end

  it "tests three Aces - reduces 2, == 21." do
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Eight")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  it "tests three Aces - reduces all 3, result < 21." do
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ten")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 13
  end

  it "tests three Aces - reduces all 3, result == 21." do
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ten")
    hand << Card.new("Diamonds", "Eight")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  it "tests three Aces - reduces all 3, busts." do
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ten")
    hand << Card.new("Diamonds", "Nine")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 22
  end

  # tests with four aces
  it "tests four Aces - reduces 3." do
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ace")
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 14
  end

  it "tests four Aces - reduces three, result < 21." do
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ace")
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Spades", "Two")
    hand << Card.new("Spades", "Four")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 20
  end

  it "tests four Aces - reduces three, result == 21." do
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ace")
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Hearts", "Seven")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  it "tests four Aces - reduces all 4, result < 21." do
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ace")
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Hearts", "Eight")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 12
  end

  it "tests four Aces - reduces all 4, result == 21." do
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ace")
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Hearts", "Eight")
    hand << Card.new("Spades", "Five")
    hand << Card.new("Spades", "Four")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 21
  end

  it "tests four Aces - reduces all 4, busts." do
    hand << Card.new("Clubs", "Ace")
    hand << Card.new("Diamonds", "Ace")
    hand << Card.new("Hearts", "Ace")
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Hearts", "Eight")
    hand << Card.new("Spades", "Jack")
    hand_value = BlackjackValue.new(hand).value
    hand_value.should == 22
  end

  # final test - for shits and giggles, mostly - get the value of the entire deck
  it "values the entire deck, including reducing all 4 Aces." do
    pending "IGNORE ME"
    deck = Deck.new   # <- to get this line to work, comment out the require line in deck.rb
    
    x = 0
    52.times do
      hand << deck.deck(x)
      x += 1
    end

    hand_value = BlackjackValue.new(hand).value
    hand_value.should == (1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + (10 * 4)) * 4
  end

  # Tests for blackjacks
  it "declares a hand a blackjack." do
    hand << Card.new("Spades", "Jack")
    hand << Card.new("Spades", "Ace")
    is_a_blackjack = BlackjackValue.new(hand).is_blackjack
    is_a_blackjack.should == true
  end

  it "declares a hand a NOT a blackjack, if it contains more than 2 cards." do
    hand << Card.new("Spades", "Ace")
    hand << Card.new("Spades", "Jack")
    hand << Card.new("Hearts", "Five")
    is_a_blackjack = BlackjackValue.new(hand).is_blackjack
    is_a_blackjack.should == false
  end 
end
