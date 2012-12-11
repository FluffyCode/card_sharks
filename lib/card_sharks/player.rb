class Player
  def initialize
    @credits = 150  # for Blackjack
    @hand = []
    @score_pool = [] # for Go Fish
  end

  # method implemented for Blackjack
  def credits
    @credits
  end

  # method implemented for Blackjack
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

  # method implemented for Crazy Eights
  def tell_hand_numbered
    index_num = 1
    temp_array = []

    @hand.each do |card|
      card_rank = card::rank
      card_suit = card::suit

      temp_array << "#{card_rank} of #{card_suit} (#{index_num})"
      index_num += 1
    end

    temp_array.join(", ")
  end

  # method implemented for Blackjack
  def update_credits(amount)
    @credits += amount
  end

  def wipe_hand
    @hand = []
  end

  # method implemented for Go Fish
  def score_pool
    @score_pool
  end

  # method implemented for Go Fish
  def add_to_score_pool(card)
    @score_pool << card
  end

  # method implemented for Go Fish
  def wipe_score_pool
    @score_pool = []
  end
end
