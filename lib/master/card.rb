class Card < Struct.new(:suit, :rank)
  RANKS = %w[Two Three Four Five Six Seven Eight Nine Ten Jack Queen King Ace]
  SUITS = %w[Clubs Diamonds Hearts Spades]

  def inspect
    to_s
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def self.ranks
    RANKS
  end

  def self.suits
    SUITS
  end
end
