require_relative "card"

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

  def self
    @deck
  end

  def delete(x)
    @deck.delete(x)
  end

  def deck(x)
    @deck[x]
  end

  def tell_deck
    @deck.join(", ")
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

  def add_card_to_deck(card)
    @deck << card
  end

  def length
    @deck.length
  end
end
