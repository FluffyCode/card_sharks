class Player
  def initialize
    @credits = 150
    @hand = []
    @score_pool = [] # for Go Fish
  end

  def credits
    @credits
  end

  def make_bid
    if @credits == 0
      puts "You are out of credits."
      exit 0
    end
    puts "How many of your #{@credits} credits would you like to wager?"
    bid = gets.chomp.to_i
    if bid > 0 && bid <= @credits
      bid
    else 
      make_bid
    end
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

  def update_credits(amount)
    @credits += amount
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
