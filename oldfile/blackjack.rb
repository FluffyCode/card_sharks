# Blackjack.rb version 3.1

# Notes on progress / current problems:

  def round_of_blackjack(player_credits, player_bid)
    player_credits = player_credits
    player_bid = player_bid

    card_suits = [" of Diamonds", " of Clubs", " of Hearts", " of Spades"]
    card_values = ["Ace", 2, 3, 4, 5, 6, 7, 8, 9, 10, "Jack", "Queen", "King"]
    def populate_deck(card_suits, card_values)
      deck = []
      @card_suit = card_suits
      @card_value = card_values

    x = 0 # card_suits index
    y = 0 # card_values index

    while deck.length < 52
      until y == 13
        if @card_value.is_a?(Integer) == false
          deck.push(@card_value[y].to_s + @card_suit[x])
          y += 1
        else
          deck.push(@card_value[y] + @card_suit[x])
          y += 1
        end
      end
      y = 0
      x += 1
    end
    deck
  end

  deck = populate_deck(card_suits, card_values)
  shuffled_deck = deck.sort_by{rand}

  def deal_card(person, shuffled_deck, deck_index)
    person.push(shuffled_deck[deck_index])
  end

  deck_index = 0

  players_hand = []
  deal_card(players_hand, shuffled_deck, deck_index)
  deck_index += 1
  deal_card(players_hand, shuffled_deck, deck_index)
  puts "You have been dealt two cards: #{players_hand.join(", ")}."
  deck_index += 1

  dealers_hand = []
  deal_card(dealers_hand, shuffled_deck, deck_index)
  deck_index += 1
  deal_card(dealers_hand, shuffled_deck, deck_index)
  deck_index += 1
  puts "The dealer has been dealt two cards, and is showing #{dealers_hand[1]}."

  def get_chomp_down
    input = gets.chomp.downcase
  end

  def hit_or_stay
    puts "Hit, or stay?"
  end

  def round_result(result, player_credits, player_bid, dealers_hand)
    result = result
    tell_dealers_hand = puts "This round, the dealer's hand contained: #{dealers_hand.join(", ")}."

    if result == "win"
      tell_dealers_hand
      puts "You started with #{player_credits} credits, and your bid was #{player_bid}."
      player_credits += (player_bid * 2)
      puts "Winning doubled your bid, and earned you #{(player_bid * 2)} credits."
      play_again(player_credits)
    elsif result == "lose"
      tell_dealers_hand
      puts "You lost your bid of #{player_bid} credits."
      player_credits -= player_bid
      play_again(player_credits)
    else
      tell_dealers_hand
      puts "It's a push.  Your #{player_bid} credit bid has been returned."
      play_again(player_credits)
    end
  end

  def tell_player_hand_and_score(players_hand)
    hand_value = evaluate_hand_score(players_hand)
    puts "Your hand contains: #{players_hand.join(", ")}."
    puts "Your hand value is #{hand_value}."
    hand_value
  end

  def hit_loop(shuffled_deck, deck_index, players_hand, player_credits, player_bid, dealers_hand)
    hit_or_stay
    until get_chomp_down == "stay"
      players_hand.push(shuffled_deck[deck_index])
      puts "Your hand contains #{players_hand.join(", ")}."
      deck_index += 1

      if evaluate_hand_score(players_hand) == 21
        # Break player out of until-loop when they hit towards 21
        puts "You have a score of 21 with: #{players_hand.join(", ")}."
        break
      else
        # Busting
        if evaluate_hand_score(players_hand) > 21
          puts "You busted."
          round_result("lose", player_credits, player_bid, dealers_hand)
        else
          hit_or_stay
        end
      end
    end
    players_hand
  end

  def evaluate_hand_score(players_hand)
    hand_score = 0
    x = 0       # indexing for the hand scoring, below
    while x < players_hand.length
      if players_hand[x].include?("Jack") || players_hand[x].include?("Queen") || players_hand[x].include?("King")
        hand_score += 10
        x += 1
      elsif players_hand[x].include?("Ace")
        hand_score += 11
        x += 1  
      elsif
        # Strip everything but the numbers from the string
        hand_score += players_hand[x].gsub(/[^0-9]/, '').to_i
        x += 1
      end
    end

    # Count the Aces
    number_of_aces = players_hand.count { |card| card.include?("Ace") }

    if hand_score > 21 && number_of_aces > 0
      until hand_score < 21 || number_of_aces == 0
        hand_score -= 10 unless number_of_aces == 0
        number_of_aces -= 1
      end
    end

    hand_score
  end

  def is_blackjack(hand)
    x = 0     # Hand indexing
    has_jack = false
    has_ace = false

    while x < hand.length
      if hand[x].include?("Ace") == true
        has_ace = true
        x = hand.length
      else
        x += 1
      end
    end

    x = 0     # Reset x

    while x < hand.length
      if hand[x].include?("Jack") == true
        has_jack = true
        x = hand.length
      else
        x += 1
      end
    end

    if has_jack == true && has_ace == true && hand.length == 2
      true
    else
      false
    end
  end

  if evaluate_hand_score(players_hand) == 21
    # If player's initial hand == 21, they are not put into the hit_loop
    puts "You have a score of 21 with: #{players_hand.join(", ")}."
    players_final_hand = players_hand
  else
    # Player gets put into the hit_loop
    # Cards are dealt on "hit," a score is kept, and the final results are saved in players_final_hand
    players_final_hand = hit_loop(shuffled_deck, deck_index, players_hand, player_credits, player_bid, dealers_hand)
  end
  # Save score as an integer in players_score
  players_score = evaluate_hand_score(players_final_hand)
  # Determine if the player's hand is a blackjack
  player_has_blackjack = is_blackjack(players_final_hand)

  # The dealers turn
  # First off, update deck_index
  deck_index = players_final_hand.length + dealers_hand.length

  # Until the value of dealers_hand > 15, they hit
  until evaluate_hand_score(dealers_hand) > 15
    dealers_hand.push(shuffled_deck[deck_index])
    puts "The dealer adds a #{shuffled_deck[deck_index]} to their hand."
    deck_index += 1
  end
  dealers_score = evaluate_hand_score(dealers_hand)
  # The dealer busts if over 21
  if dealers_score > 21
    puts "The dealer busts with #{dealers_score}."
    round_result("win", player_credits, player_bid, dealers_hand)
  end
  dealer_has_blackjack = is_blackjack(dealers_hand)

  # Final scoring
  # First, does anyone have a Blackjack?
  if player_has_blackjack == true || dealer_has_blackjack == true
    if player_has_blackjack == true && dealer_has_blackjack == false
      puts "Your Blackjack trumps the dealer."
      round_result("win", player_credits, player_bid, dealers_hand)
    elsif player_has_blackjack == false && dealer_has_blackjack == true
      puts "The dealer's Blackjack trumps your hand."
      round_result("lose", player_credits, player_bid, dealers_hand)
    elsif player_has_blackjack == true && dealer_has_blackjack == true
      puts "Both you and the dealer have a Blackjack."
      round_result("tie", player_credits, player_bid, dealers_hand)
    end

  # Second, if no Blackjacks are in anyone's hand:
elsif players_score > dealers_score
  puts "Your #{players_score} whomps the dealer's meager #{dealers_score}."
  round_result("win", player_credits, player_bid, dealers_hand)
elsif dealers_score > players_score
  puts "The dealer's #{dealers_score} eats your #{players_score} for breakfast."
  round_result("lose", player_credits, player_bid, dealers_hand)
else
  round_result("tie", player_credits, player_bid, dealers_hand)
end
end

player_credits = 150

def place_a_wage(player_credits)
  def repeat_wager_req(player_credits)
    puts "How many credits would you like to wager?"
    player_bid = gets.chomp.to_i
  end

  player_credits = player_credits

  player_bid = repeat_wager_req(player_credits)
  until player_bid > 0 && player_bid <= player_credits
    if player_bid < 1
      puts "You can't bid 0 or less!"
    elsif player_bid > player_credits
      puts "You can't bid more than you have!"
    end
    player_bid = repeat_wager_req(player_credits)
  end
  
  round_of_blackjack_results = round_of_blackjack(player_credits, player_bid)
end

def play_again(player_credits)
  if player_credits == 0
    puts "You've run out of credits."
    exit 0
  else
    puts "Care to play a round of blackjack? You have #{player_credits} credits."

    will_player_play = gets.chomp.downcase
    until will_player_play == "yes"
      if will_player_play == "no"
        puts "Alright then, another time!"
        exit 0
      else
        puts "Was expecting yes/no."
        will_player_play = gets.chomp.downcase
      end
    end

    player_credits = place_a_wage(player_credits)
  end 
end

play_again(player_credits)
