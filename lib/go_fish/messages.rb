class GoFishMessages
  def message(req_msg, optns={})
    puts ""

    case req_msg
    when "tell_hand"
      puts "Player hand: #{@player.tell_hand}."

    when "game_end"
      puts "The game is over; you have #{p_score} sets, and the dealer has #{d_score} sets."

      puts ""
      if optns[:p_score] > optns[:d_score]
        puts "You won this round!"
      else
        puts "The dealer won this round."
      end
      
    end
      
  end
  
end
