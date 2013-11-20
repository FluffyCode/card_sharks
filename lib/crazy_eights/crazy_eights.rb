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
    @msg_handler.message("begin", :card => @discard_pile[-1])

    # Starting the game:
    update_playable_suit
    players_turn
  end

  def update_playable_suit
    @playable_suit = @discard_pile[-1]::suit
  end

  def get_info
    @msg_handler.message("info", :p_cards => @player.hand.size, :d_cards => @dealer.hand.size,
      :rank => @discard_pile[-1]::rank, :suit => @playable_suit, :draw => @deck.length, :discard => @discard_pile.length
    )

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
          @msg_handler.message("bad_play", :card => @player.hand[@user_input])
          players_turn
        end

      else
        @msg_handler.message("bad_input", :size => @player.hand.length)
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
      @msg_handler.message("game_win")
      exit 0
    elsif @dealer.hand.length == 0
      @msg_handler.message("game_lose")
      exit 0
    end

    is_an_eight = true if @discard_pile[-1]::rank == "Eight"

    if is_an_eight
      if player == "player"
        @msg_handler.message("nominate_rank")

        @new_suit = gets.chomp.downcase.capitalize!
        if @new_suit == "Clubs" || @new_suit == "Diamonds" || @new_suit == "Hearts" || @new_suit == "Spades"
          @playable_suit = @new_suit
          @msg_handler.message("player_new_suit", :suit => @new_suit, :card => @discard_pile[-1])

          dealers_turn
        else
          @msg_handler.message("bad_suit_input")
          intermediary_stage(player)
        end

      else
        @playable_suit = @dealer.hand[rand(@dealer.hand.length)]::suit
        @msg_handler.message("dealer_new_suit", :suit => @playable_suit)

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
      @msg_handler.message("dealer_plays", :card => chosen_card)
      @discard_pile << @dealer.hand.delete(chosen_card)

      intermediary_stage("dealer")
    else
      if @deck.deck(0) != nil
        @dealer.deal(@deck.remove_top_card)
        @msg_handler.message("dealer_draws")
        dealers_turn
      else
        @msg_handler.message("dealer_cant_play")
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
    # Take all the cards from the discard pile, and put them back into the deck
    @deck.add_card_to_deck(@discard_pile.delete_at(-1)) until @discard_pile.size == 0

    # Shuffle the deck
    5.times { @deck.shuffle! }

    # Place a card from the reshuffled deck onto the discard pile
    @discard_pile << @deck.remove_top_card
    update_playable_suit

    @msg_handler.message("reshuffle")

    invert_player_turn(player)
  end

end # end of CrazyEights class

CrazyEights.new
