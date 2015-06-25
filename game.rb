require_relative 'board.rb'
require 'colorize'

class Game

  def initialize(p1,p2)
    @board = Board.new
    @player1 = p1
    @player2 = p2
  end

  def parse
    gets.chomp.split(" ").map {|el| el.to_i}
  end

  def play
    curr, other = @player1, @player2
    puts "Welcome to Chess - the world's greatest board game!".colorize(:blue)
    puts "White goes first.".colorize(:blue)

    until @board.checkmate?(other.color)
      @board.display
      puts "Grab a piece, #{curr.name}!"
      piece = parse
      if @board[piece].nil? || @board[piece].color != curr.color
        system "clear"
        puts "Not your piece, #{curr.name}!"
        next
      end
      puts "Make Your Move!"
      mv = parse
      begin
        @board.move!(piece,mv)
      rescue RuntimeError => e
        system "clear"
        puts "Bad Move! Try again, #{curr.name}."
        next
      end
      system "clear"
      curr, other = other, curr
    end
    system "clear"
    @board.display
    puts "You Win, #{curr.name}"
  end
end

class HumanPlayer
  attr_reader :color ,:name
  def initialize(color, name)
    @color = color
    @name = name
  end
end

if __FILE__ == $PROGRAM_NAME
  Game.new(HumanPlayer.new(:w,"Player1"),HumanPlayer.new(:b,"Player2")).play
end
