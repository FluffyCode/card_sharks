# crazy_eights.rb version 2.5

require_relative "../master/deck"
require_relative "../master/player"
require_relative "../master/dealer"

# Game rules:
  # As per http://www.pagat.com/eights/crazy8s.html

  # Use standard 52-card deck.
  # 7 cards are dealt to both the player and dealer.
  # Remaining cards are placed face-down in a draw-pile.
  # The top card in the draw-pile is then played face-up.

  # Players take turns playing cards on top of the face-up (discard) pile.
  # If the face-up card is not an 8, only cards of the same rank or suit can be played on it.
    # Ie, if the card is a 4 of Spades, the only cards that can be played on top of it are
    # a 4 of any other suit, OR any rank as long as it is a Spade.

    # Exception: an 8 can be played on any suit/rank.  This is where "Crazy Eights" gets "crazy."

  # Eights can be played on any card.
  # When an 8 is played, the player placing the card declares a suit.
    # Only cards with the declared suit can be placed on top of the "crazy" eight.

    # Exception: players can place another 8 on top of an 8, and declare a new suit, themselves.

  # The first player to get rid of all their cards wins.
  # Losing player scores "penalty points" based on what cards they have left:
    # Any eight = 50 points.
    # Jack, Queen, King = 10 points.
    # All other cards at face value (Ace = 1, 2 = 2, etc...)

  # If a player cannot play a legal card, they must draw from the draw-pile.
  # If no cards remain in the draw-pile, play continues as normal without drawing.



class CrazyEights
  def initialize
    @player = Player.new
    @dealer = Dealer.new

    # For keeping track of the playable suit:
    @playable_suit = nil
  end

  def round_of_crazy_eights
    @deck = Deck.new
    5.times { @deck.shuffle! }

    7.times { @player.deal(@deck.remove_top_card) }
    7.times { @dealer.deal(@deck.remove_top_card) }

    # Next card taken from the deck becomes the start of the discard pile
    @discard_pile = Array.new << @deck.remove_top_card
    puts ""
    puts "The game begins - the top card is #{@discard_pile[-1]}."

    def update_playable_suit
      @playable_suit = @discard_pile[-1]::suit
    end

    def get_info
      update_playable_suit

      def determine_plural(value)
        if value == 1
          return "#{value} card"
        else
          return "#{value} cards"
        end
      end

      puts
      puts "You have #{determine_plural(@player.hand.size)} in your hand, and the dealer has #{determine_plural(@dealer.hand.size)}."
      puts "The current playable rank is #{@discard_pile[-1]::rank}, and the current playable suit is #{@playable_suit}."
      puts "There are #{determine_plural(@deck.length)} in the draw pile, and #{determine_plural(@discard_pile.length)} in the discard pile."

      players_turn
    end

    def check_for_match(card_being_played)
      if card_being_played::rank == @discard_pile[-1]::rank || card_being_played::suit == @playable_suit || card_being_played::rank == "Eight"
        true
      end
    end

    def players_turn
      puts
      puts "What card would you like to play?  Your hand contains:"
      puts "#{@player.tell_hand_numbered}"
      puts
      puts "Type 'pass' to draw a card, or pass."
      puts "Type 'info' to get game info."
      # User is prompted for input
      @user_input = gets.chomp

      # If the user choses to pass...
      if @user_input.downcase == "pass"
        if @deck.length == 0
          time_to_reshuffle_deck("dealer")
          dealers_turn
        else
          @player.deal(@deck.remove_top_card)
          puts ""
          puts "You draw #{@player.hand[-1]} from the draw pile."
          players_turn
        end

      # ...elsif the input is "info" (player requests info)...
      elsif @user_input.downcase == "info"
        get_info

      # ...else, in regards to playing a card...
      else
        @user_input = @user_input.to_i
      
        if @user_input > 0 && @user_input < @player.hand.length + 1
          @user_input -= 1

          if check_for_match(@player.hand[@user_input])
            puts ""
            puts "You play your #{@player.hand[@user_input]}."
            @discard_pile << @player.hand.delete_at(@user_input)

            intermediary_stage("player")      
          else
            puts ""
            puts "You cannot play #{@player.hand[@user_input]} - either rank or suit (or both) does not match."
            players_turn
          end

        else
          puts ""
          puts "Error: was expecting 'pass' or an integer between 1 and #{@player.hand.length}."
          players_turn
        end
      end

    end # end of players_turn

    # Determine if conditions are appropriate for deck reshuffling
    def time_to_reshuffle_deck(player)
      player_can_make_play = false
      dealer_can_make_play = false

      @player.hand.each do |card|
        if check_for_match(card)
          player_can_make_play = true
        end
      end

      @dealer.hand.each do |card|
        if check_for_match(card)
          dealer_can_make_play = true
        end
      end

      if (player_can_make_play == false) && (dealer_can_make_play == false)
        replace_deck(player)
      end
    end

    # Intermediary stage - check for game overs, & the play of 8's here
    def intermediary_stage(player)
      update_playable_suit

      is_an_eight = true if @discard_pile[-1]::rank == "Eight"

      if @player.hand.length == 0
        puts ""
        puts "You were the first to clear all cards from your hand - you win!"
        exit 0
      elsif @dealer.hand.length == 0
        puts ""
        puts "The dealer was first to clear their hand of all cards and won this game."
        exit 0
      end

      if is_an_eight
        if player == "player"
          puts ""
          puts "You played an Eight - nominate a new rank: Clubs, Diamonds, Hearts or Spades."

          @new_suit = gets.chomp.downcase.capitalize!
          if @new_suit == "Clubs" || @new_suit == "Diamonds" || @new_suit == "Hearts" || @new_suit == "Spades"
            @playable_suit = @new_suit
            puts ""
            puts "You chose to change the playable suit to: #{@new_suit}."
            puts ""
            puts "The top card on the discard pile is: #{@discard_pile[-1]}."

            dealers_turn
          else
            puts ""
            puts "Error: was expecting a string for a new suit."
            intermediary_stage(player)
          end

        elsif player == "dealer"
          random_num = rand(@dealer.hand.length)

          @playable_suit = @dealer.hand[random_num]::suit

          puts ""
          puts "The dealer played an Eight, and decided to change the suit to #{@dealer.hand[random_num]::suit}."

          players_turn
        end
      end
      
      invert_player_turn(player)
    end # end of intermediary_stage

    # Dealers turn
    def dealers_turn
      can_play_these = []

      @dealer.hand.each do |card|
        if check_for_match(card)
          can_play_these << card
        end
      end

      if can_play_these.length > 0
        chosen_card = can_play_these[rand(can_play_these.length)]

        puts ""
        puts "The dealer plays their #{chosen_card}."
        @discard_pile << @dealer.hand.delete(chosen_card)

        intermediary_stage("dealer")
      else
        if @deck.deck(0) != nil
          @dealer.deal(@deck.remove_top_card)
          puts ""
          puts "The dealer was unable to play a card, and draws from the draw pile."
          dealers_turn
        else
          puts ""
          puts "The dealer was unable to play a card."
          time_to_reshuffle_deck("player")
          players_turn
        end 
      end
    end # end of dealers_turn

    def invert_player_turn(player)
      players_turn if (player == "dealer")
      dealers_turn if (player == "player")
    end

    # Deck reshuffling (in case no legal plays can be made && draw pile is empty)
    def replace_deck(player)
      puts ""
      puts "The draw pile is empty, and no plays can be made."

      # Take all the cards from the discard pile, and put them back into the deck
      until @discard_pile.size == 0
        @deck.add_card_to_deck(@discard_pile.delete_at(-1))
      end

      # Shuffle the deck
      5.times { @deck.shuffle! }

      # Place a card from the reshuffled deck onto the discard pile
      @discard_pile << @deck.remove_top_card
      update_playable_suit

      puts "The discard pile has been reshuffled into the draw pile."

      invert_player_turn(player)
    end

    # Starting the game:
    update_playable_suit
    players_turn
  end # end of round_of_crazy_eights

end # end of CrazyEights class

CrazyEights.new.round_of_crazy_eights
