require "./Card"

class Deck
  SIZE = 52

  def initialize 
    @deck = []

    SIZE.times do |i|
      rank = Card.ranks[i % 13]
      suit = Card.suits[i % 4]

      @deck << Card.new(suit, rank)
    end
  end

  def sort!
    @deck.sort_by do |card|
      card.suit
    end
  end

  def shuffle!
    @deck.shuffle!
  end

  def remove_top_card
    @deck.delete_at(0)
  end
end
