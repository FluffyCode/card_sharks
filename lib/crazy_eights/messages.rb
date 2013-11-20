class CrazyEightsMessages
  def message(req_msg, optns={})
    puts ""

    case req_msg
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

    end
  end

end
