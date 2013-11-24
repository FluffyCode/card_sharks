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

    when "score"
      puts "#{optns[:context]} with a set of #{optns[:rank]}."

    when "no_cards"
      puts "#{optns[:context]} out of cards."

    when "dealer_asks"
      puts "The dealer asks for: #{optns[:card]}."

    when "pass_cards"
      if optns[:giver] == "player"
        puts "You pass the dealer your #{optns[:card]}."
      else
        puts "The dealer passes you their #{optns[:card]}."
      end

    when "dealer_doesnt_get"
      puts "The dealer didn't get a #{optns[:card]}, and goes fishing instead."

    when "player_doesnt_get"
      puts "The dealer did not have any: #{optns[:card]}."

    when "cant_ask"
      puts "You cannot ask for that, as you do not have any."

    when "player_fishes"
      puts "You fished a #{optns[:card]} from the pool."

    when "no_fish"
      puts "There are no more fish in the pool."

    when "got_asking_card"
      if optns[:player] == "player"
        puts "You got what you asked for! You get another turn."
      else
        puts "The dealer got what they asked for, and gets another turn."
      end

    when "player_turn"
      puts "What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)"

    when "first_turn"
      puts "#{optns[:context]} the first turn."

    when "greet"
      puts "Would you like to play a game of Go Fish?"

    when "farewell"
      puts "Alrighty then, another time!"

    end
      
  end
  
end
