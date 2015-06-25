require_relative 'piece.rb'
require 'colorize'

class Board
  def initialize(options = {})
    defaults = { :board_start => true }
    @board = Array.new(8) { Array.new(8) }
    options = defaults.merge(options)
    set_board if options[:board_start]
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos,val)
    row, col = pos
    @board[row][col] = val
  end

  def in_check?(color)
    king = nil
    @board.each do |row|
      row.each do |piece|
        if !piece.nil? && piece.type == :king && piece.color == color
          king = piece
          break
        end
      end
    end
    opposing_pieces(color).any?{|piece| piece.moves.include?(king.pos)}
  end

  def move(start_pos,end_pos)
    piece_to_move = @board[start_pos[0]][start_pos[1]]
    if piece_to_move == nil
      raise
    end
    if piece_to_move.moves.include?(end_pos)
      piece_to_move.move(end_pos)
      @board[end_pos[0]][end_pos[1]] = piece_to_move
      @board[start_pos[0]][start_pos[1]] = nil
    else
      raise
    end
  end

  def move!(start_pos,end_pos)
    piece_to_move = @board[start_pos[0]][start_pos[1]]
    if piece_to_move == nil
      raise "Piece not there"
    end
    if piece_to_move.valid_moves.include?(end_pos)
      piece_to_move.move(end_pos)
      @board[end_pos[0]][end_pos[1]] = piece_to_move
      @board[start_pos[0]][start_pos[1]] = nil
    else
      raise "Invalid move."
    end
  end

  def opposing_pieces(color)
    opposing_pieces = []
    @board.each do |row|
      row.each do |piece|
        if !piece.nil? && piece.color == opposite_color(color)
          opposing_pieces << piece
        end
      end
    end
    opposing_pieces
  end

  def opposite_color(color)
    color == :b ? :w : :b
  end

  def checkmate?(color)
    in_check?(color) && no_valid_moves(color)
  end

  def no_valid_moves(color)
    v_moves = []
    @board.each do |row|
      row.each do |piece|
        if !piece.nil? && piece.color == color
          v_moves << piece.valid_moves
        end
      end
    end

    v_moves.flatten(1).count > 0 ? true : false
  end

  def set_board
    @board[6].each_with_index do |piece, index|
      @board[6][index] = Pawn.new(self, [6, index], :w)
    end
    @board[7][0] = SlidingPiece.new(self,[7,0],:w,:rook)
    @board[7][7] = SlidingPiece.new(self,[7,7],:w,:rook)
    @board[7][1] = SteppingPiece.new(self,[7,1],:w,:knight)
    @board[7][6] = SteppingPiece.new(self,[7,6],:w,:knight)
    @board[7][2] = SlidingPiece.new(self,[7,2],:w,:bishop)
    @board[7][5] = SlidingPiece.new(self,[7,5],:w,:bishop)
    @board[7][3] = SlidingPiece.new(self,[7,3],:w,:queen)
    @board[7][4] = SteppingPiece.new(self, [7, 4], :w, :king)

    @board[1].each_with_index do |piece,index|
      @board[1][index] = Pawn.new(self,[1,index],:b)
    end
    @board[0][7] = SlidingPiece.new(self,[0,7],:b,:rook)
    @board[0][0] = SlidingPiece.new(self,[0,0],:b,:rook)
    @board[0][1] = SteppingPiece.new(self,[0,1],:b,:knight)
    @board[0][6] = SteppingPiece.new(self,[0,6],:b,:knight)
    @board[0][2] = SlidingPiece.new(self,[0,2],:b,:bishop)
    @board[0][5] = SlidingPiece.new(self,[0,5],:b,:bishop)
    @board[0][3] = SlidingPiece.new(self,[0,3],:b,:queen)
    @board[0][4] = SteppingPiece.new(self,[0,4],:b,:king)
  end

  def display
    puts "    0".colorize(:green) + "  1".colorize(:green) +
    "  2".colorize(:green)+ "  3".colorize(:green) +
    "  4".colorize(:green) + "  5".colorize(:green) +
    "  6".colorize(:green) + "  7".colorize(:green)
    squares = 0
    (0..7).each do |r|
      line = "#{r}  ".colorize(:green)
      (0..7).each do |c|
        piece = @board[r][c]
        if piece != nil
          if squares % 2 == 0
            line += (" " + piece.print).colorize( :background => :blue)
          else
            line += (" " + piece.print).colorize( :background => :red)
          end
        else
          if squares % 2 == 0
            line += "   ".colorize( :background => :blue)
          else
            line += "   ".colorize( :background => :red)
          end
        end
        squares += 1
      end
      squares -= 1
      puts line
    end
    puts ""
  end

  def dup
    dup_board = Board.new({:board_start => false})
    @board.each_with_index do |row,i|
      row.each_with_index do |col,j|
        piece = @board[i][j]
        if piece != nil
          piece = piece.dup(dup_board)
        end
        dup_board[[i,j]] = piece
      end
    end
    dup_board
  end
end
