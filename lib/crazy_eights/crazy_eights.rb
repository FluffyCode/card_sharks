# crazy_eights.rb version 2.5

require_relative "../master/deck"
require_relative "../master/player"
require_relative "../master/dealer"
require_relative "messages"

# To-do:
  # Add catch - deny player the ability to pass if they can make a legal play?



class CrazyEights
  def initialize
    @msg_handler = CrazyEightsMessages.new

    @player = Player.new
    @dealer = Dealer.new

    @deck = Deck.new
    5.times { @deck.shuffle! }

    7.times { @player.deal(@deck.remove_top_card) ; @dealer.deal(@deck.remove_top_card) }

    # Next card taken from the deck becomes the start of the discard pile
    @discard_pile = Array.new << @deck.remove_top_card
    puts ""
    puts "The game begins - the top card is #{@discard_pile[-1]}."

    # Starting the game:
    update_playable_suit
    players_turn
  end

  def update_playable_suit
    @playable_suit = @discard_pile[-1]::suit
  end

  def get_info
    def determine_plural(value)
      value == 1 ? "#{value} card" : "#{value} cards"
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

  def can_make_valid_play(player)
    can_make_play = false

    player.hand.each do |card|
      can_make_play = true if check_for_match(card)
    end

    can_make_play
  end

  def players_turn
    @msg_handler.message("player_turn", :player => @player)

    # User is prompted for input
    @user_input = gets.chomp

    # If the user choses to pass...
    if @user_input.downcase == "pass"
      if @deck.length == 0
        time_to_reshuffle_deck("dealer")
        dealers_turn
      else
        @player.deal(@deck.remove_top_card)
        @msg_handler.message("player_draws", :player => @player)
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
          @msg_handler.message("player_plays", :player => @player, :card => @user_input)
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
    replace_deck(player) unless can_make_valid_play(@player) || can_make_valid_play(@dealer)
  end

  # Intermediary stage - check for game overs, & the play of 8's here
  def intermediary_stage(player)
    update_playable_suit

    if @player.hand.length == 0
      puts ""
      puts "You were the first to clear all cards from your hand - you win!"
      exit 0
    elsif @dealer.hand.length == 0
      puts ""
      puts "The dealer was first to clear their hand of all cards and won this game."
      exit 0
    end

    is_an_eight = true if @discard_pile[-1]::rank == "Eight"

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

      else
        @playable_suit = @dealer.hand[rand(@dealer.hand.length)]::suit

        puts ""
        puts "The dealer played an Eight, and decided to change the suit to #{@playable_suit}."

        players_turn
      end
    end
    
    invert_player_turn(player)
  end # end of intermediary_stage

  # Dealers turn
  def dealers_turn
    can_play_these = []

    @dealer.hand.each do |card|
      can_play_these << card if check_for_match(card)
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
    @deck.add_card_to_deck(@discard_pile.delete_at(-1)) until @discard_pile.size == 0

    # Shuffle the deck
    5.times { @deck.shuffle! }

    # Place a card from the reshuffled deck onto the discard pile
    @discard_pile << @deck.remove_top_card
    update_playable_suit

    puts "The discard pile has been reshuffled into the draw pile."

    invert_player_turn(player)
  end

end # end of CrazyEights class

CrazyEights.new
