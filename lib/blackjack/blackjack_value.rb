class BlackjackValue
  def initialize(hand)
    @hand = hand
  end

  def values
    {"Two" => 2, "Three" => 3, "Four" => 4, "Five" => 5, "Six" => 6,
    "Seven" => 7, "Eight" => 8, "Nine" => 9, "Ten" => 10, "Jack" => 10,
    "Queen" => 10, "King" => 10, "Ace" => 11}
  end

  def value
    hand_value = @hand.reduce(0) { |sum, card| sum + values[card.rank] }

    ace_count = @hand.count { |card| card.include?("Ace") }
    if hand_value > 21 && ace_count > 0
      until hand_value <= 21 || ace_count == 0
        hand_value -= 10 unless ace_count == 0
        ace_count -= 1
      end
    end
    
    hand_value
  end

  def is_blackjack
    if @hand.length > 2
      false
    else
      has_ace = has_jack = nil

      @hand.each { |c| has_ace  = true if c[:rank] == "Ace"  }
      @hand.each { |c| has_jack = true if c[:rank] == "Jack" }

      true if has_ace && has_jack
    end
  end
end
