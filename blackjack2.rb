# OOP version of Blackjack game
# Largely copied from the solution code
# Hoping to do a more personalized version in the future

class Card
  attr_accessor :suit, :value
  
  def initialize (s, v)
    @suit = s
    @value = v
  end
  
  def to_s
    "#{value} of #{suit}"
  end
end

class Deck
  attr_accessor :cards
  
  def initialize
    @cards = []
    ['Hearts', 'Diamonds', 'Spades', 'Clubs'].each do |suit|
      [2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King', 'Ace'].each do |value|
        @cards << Card.new(suit, value)
      end
    end
    mix_cards!
  end

  def deal_one
    cards.pop
  end
  
  def mix_cards!
    cards.shuffle!
  end
    
end

module Hand 

  def show_hand
    puts "------- #{name}'s hand is -------"
      cards.each do |card| 
        puts "=> #{card}"
      end
    puts "Total is: #{hand_value}"
  end

  def take_card(new_card)
    cards << new_card
  end

  def is_busted?
    hand_value > Blackjack::BLACKJACK_AMOUNT
  end
  
  def has_blackjack?
    hand_value == Blackjack::BLACKJACK_AMOUNT
  end

  def hand_value
  value = 0
    cards.each do |card|
      if card.to_s.include?('Ace')
        value += 11
      elsif card.to_s.to_i == 0
        value += 10
      else
        value += card.to_s.to_i
      end
    end
    cards.select {|aces| aces == (cards.to_s[0] == 'A')}.count.times do
      value -= 10 if value > 21
    end
    value
  end
 
end

class Dealer
  include Hand
  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end
  
  def first_show
    puts "------- #{name}'s first card is -------"
    puts "=> #{cards[0]} (second card is hidden)"
    # puts "Total value showing is: #{hand_value}"
  end
  
end

class Player
  include Hand
  attr_accessor :name, :cards

  def initialize(p_name)
    @name = p_name
    @cards = []
  end
  
end

# Game engine

class Blackjack 
  attr_accessor :deck, :player, :dealer
  
  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new('Buddy')
    @dealer = Dealer.new
  end

  def set_player_name
    puts '------- Welcome to Ruby Blackjack! -------'
    print 'Please enter your name => '
    player.name = gets.chomp
  end

  def first_deal
    2.times do
      player.take_card(deck.deal_one)
      dealer.take_card(deck.deal_one)
    end
    dealer.first_show
  end
  
  def player_turn
    
    if player.has_blackjack?
      player.show_hand
      puts "You have blackjack, #{player.name}! You win!"
      play_again?
    end
    
    response = ''
    while (player.hand_value <= BLACKJACK_AMOUNT) && (response.upcase != 'S')
      player.show_hand
      puts "#{player.name}, would you like to [H]it or [S]tay?"
      response = gets.chomp
        if response.upcase == 'H'
          new_card = deck.deal_one
          player.take_card(new_card)
        elsif response.upcase != ('S' || 'H')
          puts "Please enter [H] for Hit or [S] for Stay"
        end
    end  
    
    if player.hand_value > BLACKJACK_AMOUNT
      player.show_hand
      puts "Sorry #{player.name}, you busted!"
      play_again?
    end
  end
  
  def dealer_turn
    if dealer.has_blackjack?
      dealer.show_hand
      puts "Dealer has blackjack!"
      compare_scores(dealer, player)
    end
    while dealer.hand_value < DEALER_HIT_MIN
      dealer.show_hand
      new_card = deck.deal_one
      dealer.take_card(new_card)
    end
    if dealer.hand_value > BLACKJACK_AMOUNT
      dealer.show_hand
      puts "Dealer busted! You win!"
      play_again?
    end
  end
  
  def compare_scores dealer, player
    if player.hand_value > dealer.hand_value
      puts "You win, #{player.name}!"
      play_again?
    elsif dealer.hand_value > player.hand_value
      puts "Sorry, #{dealer.name} wins!"
      play_again?
    else
      puts "It's a tie! Imagine that!"
      play_again?
    end
  end
  
  def play_again?
    puts "------- GAME OVER -------"
    replay = ''
    while (replay.upcase != 'Y') || (replay.upcase != 'N')
    print "Would you like to play again? [Y]es or [N]o? => "
    replay = gets.chomp
      if replay.upcase == 'Y'
        puts "------- Starting new game -------"
        puts ''
        deck = Deck.new
        player.cards = []
        dealer.cards = []
        start
      elsif replay.upcase == 'N'
        puts "Thanks for playing!"
        exit
      end
    puts "Please enter [Y] for Yes or [N] for No"
    end
  end
  
  def start
    set_player_name
    first_deal
    player_turn
    dealer_turn
    compare_scores
  end
end

game = Blackjack.new
game.start
