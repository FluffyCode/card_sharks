class CrazyEightsMessages
  def pluralize(value)
    value == 1 ? "#{value} card" : "#{value} cards"
  end
  
  def message(req_msg, optns={})
    puts ""

    case req_msg
    when "begin"
      puts "The game begins - the top card is #{optns[:card]}."

    when "player_turn"
      puts "What card would you like to play?  Your hand contains:"
      puts "#{optns[:player].tell_hand_numbered}"
      puts
      puts "Type 'pass' to draw a card, or pass."
      puts "Type 'info' to get game info."

    when "player_draws"
      puts "You draw #{optns[:player].hand[-1]} from the draw pile."

    when "player_plays"
      puts "You play your #{optns[:player].hand[optns[:card]]}."

    when "bad_play"
      puts "You cannot play #{optns[:card]} - either rank or suit (or both) does not match."

    when "bad_input"
      puts "Error: was expecting 'pass' or an integer between 1 and #{optns[:size]}."

    when "game_win"
      puts "You were the first to clear all cards from your hand - you win!"

    when "game_lose"
      puts "The dealer was first to clear their hand of all cards and won this game."

    when "nominate_rank"
      puts "You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades."

    when "player_new_suit"
      puts "You chose to change the playable suit to: #{optns[:suit]}."
      puts
      puts "The top card on the discard pile is: #{optns[:card]}."

    when "bad_suit_input"
      puts "Error: was expecting a string for a new suit."

    when "dealer_plays"
      puts "The dealer plays their #{optns[:card]}."

    when "dealer_new_suit"
      puts "The dealer played an Eight, and decided to change the suit to #{optns[:suit]}."

    when "dealer_draws"
      puts "The dealer was unable to play a card, and draws from the draw pile."

    when "dealer_cant_play"
      puts "The dealer was unable to play a card."

    when "reshuffle"
      puts "The draw pile is empty, and no plays can be made."
      puts "The discard pile has been reshuffled into the draw pile."

    when "info"
      puts "You have #{pluralize(optns[:p_cards])} in your hand, and the dealer has #{pluralize(optns[:d_cards])}."
      puts "The current playable rank is #{optns[:rank]}, and the current playable suit is #{optns[:suit]}."
      puts "There are #{pluralize(optns[:draw])} in the draw pile, and #{pluralize(optns[:discard])} in the discard pile."

    end
  end

end
