class AddACardValue
  def cards(c)
    @cards = c
  end

  def values
    {"Two" => 2, "Three" => 3, "Four" => 4, "Five" => 5, "Six" => 6,
    "Seven" => 7, "Eight" => 8, "Nine" => 9, "Ten" => 10, "Jack" => 10,
    "Queen" => 10, "King" => 10, "Ace" => 10}
  end

  def value
    @cards.reduce(0) do |sum_of_values, card|
      sum_of_values + values[card.rank]
    end
  end
end
