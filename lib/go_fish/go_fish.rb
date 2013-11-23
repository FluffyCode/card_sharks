# go_fish.rb version 1.1

# List of thing to do/fix:
  # Refactor
  # Move messages to their own file; make use of a message handler
  # Touchup messages with spacing
  # Review game notes and make changes as needed



require_relative "../master/deck"
require_relative "../master/player"
require_relative "../master/dealer"
require_relative "messages"

class GoFish
  def initialize
    @player = Player.new
    @dealer = Dealer.new

    @msg_handler = GoFishMessages.new
  end

  def round_of_go_fish
    @player.wipe_hand
    @dealer.wipe_hand

    @deck = Deck.new
    @deck.shuffle!

    # Initial deal; 7 cards go to each player:
    7.times { @player.deal(@deck.remove_top_card); @dealer.deal(@deck.remove_top_card) }

    @msg_handler.message("tell_hand")

    def check_for_game_over
      player_score = @player.score_pool.length / 4
      dealer_score = @dealer.score_pool.length / 4
      if player_score + dealer_score == 13
        @msg_handler.message("game_end", :p_score => player_score, :d_score => dealer_score)
        play_a_game
      end
    end

    def find_matching_set(player)
      # look for matching sets
      ranks_to_search_for = []
      is_set_of_four = 0
      player.hand.each do |card|
        ranks_to_search_for << card::rank
      end

      ranks_to_search_for.each do |rank|
        @cards_to_score = player.hand.find_all { |card| card.include?(rank) }
        if @cards_to_score.length == 4
          is_set_of_four = 1
          @last_rank_called = rank
          break
        end
      end

      # score with the matching sets
      if is_set_of_four == 1
        @cards_to_score.each do |card_a|
          player.hand.each do |card_b|
            player.hand.delete(card_b) if card_b == card_a
          end
        end

        until @cards_to_score.length == 0
          player.add_to_score_pool(@cards_to_score.delete(@cards_to_score[0]))
        end
        
        # tell the player (or dealer) what they scored with
        if player == @player
          puts "You score with a set of #{@last_rank_called}."
        else
          puts "The dealer scores with a set of #{@last_rank_called}."
        end
      end

      # check for game over
      check_for_game_over
    end

    def dealers_turn
      # If the dealer has no cards remaining:
      if @dealer.hand.length == 0
        puts "The dealer is out of cards."
        ask_for(0)
      end

      # dealer gets a pool of ranks to chose from:
      cards_to_chose_from = []
      # populate the choice-pool:
      @dealer.hand.each do |card|
        cards_to_chose_from << card::rank
      end
      # randomly determine which card the dealer will ask for:
      random_card = cards_to_chose_from[rand(cards_to_chose_from.length)]

      # ask for it:
      puts "The dealer asks for: #{random_card}."

      got_what_they_asked_for = false

      # indexing through the player's hand
      x = 0
      
      until @player.hand[x] == nil
        if @player.hand[x].include?(random_card)
          puts "You pass the dealer your #{@player.hand[x]}."
          @dealer.deal(@player.hand.delete(@player.hand[x]))
          got_what_they_asked_for = true
        else
          x += 1
        end
      end

      if got_what_they_asked_for == true
        find_matching_set(@dealer)
        ask_for(2)
      else
        puts "The dealer didn't get a #{random_card}, and goes fishing instead."
        go_fish(random_card, @dealer)
        ask_for(0)
      end
    end

    def player_turn(requested_card)
      # If the player has no cards remaining:
      if @player.hand.length == 0
        puts "You are out of cards."
        dealers_turn
      end

      got_what_they_asked_for = false
      can_ask_for = false

      @player.hand.each do |card|
        can_ask_for = true if card.include?(requested_card)
      end

      if can_ask_for == true
        x = 0
        
        until @dealer.hand[x] == nil
          if @dealer.hand[x].include?(requested_card)
            puts "The dealer passes you their #{@dealer.hand[x]}."
            @player.deal(@dealer.hand.delete(@dealer.hand[x]))
            got_what_they_asked_for = true
          else
            x += 1
          end
        end
      else
        puts "You cannot ask for that, as you do not have any."
        ask_for(0)
      end

      if got_what_they_asked_for == true
        find_matching_set(@player)
        ask_for(1)
      else
        puts "The dealer did not have any: #{requested_card}."
        go_fish(requested_card, @player)
        dealers_turn
      end
    end

    def go_fish(card, player)
      if @deck.deck(0) != nil
        card_to_deal = @deck.remove_top_card
        player.deal(card_to_deal)
        
        # Tell the player what they got (but don't tell the player what the dealer got):
        if player == @player
          puts "You fished a #{card_to_deal} from the pool."
        end

        find_matching_set(player) # find_matching_set here, after being dealt a card from the "pool"

        # The player gets another turn if they got what they asked for:
        if card_to_deal.include?(card)
          if player == @dealer
            ask_for(2)
          else
            ask_for(1)
          end
        end

      else
        # Don't deal a card if there are none left
        puts "There are no more fish in the pool."

        if player == @dealer
          ask_for(0)
        else
          dealers_turn
        end
      end
    end

    def ask_for(x)
      if x == 1
        puts "You got what you asked for! You get another turn."
      elsif x == 2
        puts "The dealer got what they asked for, and gets another turn."
        dealers_turn
      end

      puts "What rank do you want to ask your opponent for? (Type 'hand' to see your hand.)"
      requested_card = gets.chomp
      if requested_card == "hand"
        puts
        puts "Player hand: #{@player.tell_hand}."
        puts
        ask_for(0)
      else
        player_turn(requested_card)
      end
    end

    # determine who goes first
    def who_goes_first
      if rand(2) == 1
        puts "You get the first turn."
        ask_for(0)
      else
        puts "The dealer gets the first turn."
        dealers_turn
      end
    end

    # First-time check for any matching sets:
    find_matching_set(@player)
    find_matching_set(@dealer)

    who_goes_first
  end
end

def play_a_game
  puts "Would you like to play a game of Go Fish?"
  if gets.chomp.downcase == "yes"
    GoFish.new.round_of_go_fish
  else 
    puts "Alrighty then, another time!"
    exit 0
  end
end

play_a_game
