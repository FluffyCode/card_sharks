class Dealer
  def initialize
    @hand = []
    @score_pool = [] # for Go Fish
  end

  def deal(card)
    @hand << card
  end

  def hand
    @hand
  end

  def tell_hand
    @hand.join(", ")
  end

  def wipe_hand
    @hand = []
  end

  def score_pool
    @score_pool
  end

  def add_to_score_pool(card)
    @score_pool << card
  end

  def wipe_score_pool
    @score_pool = []
  end
end
