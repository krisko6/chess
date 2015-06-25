class Piece
  attr_accessor :board, :pos, :color

  def initialize(board, pos, color)
    @board = board
    @pos = pos
    @color = color
    @move_count = 0
  end

  def moves
    raise "Can't call method on this class"
  end

  def move(position)
    @pos = position
    @move_count += 1
  end

  def valid_moves
    moves.reject { |a, b| move_into_check?([a, b]) }
  end

  def move_into_check?(position)
    dup_board = @board.dup
    dup_board.move(@pos.dup, position)
    dup_board.in_check?(@color)
  end

  def dup(b)
    raise "Can't be duped!"
  end

  def inspect
    "#{@color} #{@type}"
  end
end

class SlidingPiece < Piece

  attr_reader :type
  def initialize(board, pos, color, type)
    super(board, pos, color)
    @type = type
  end

  def dup(b)
    self.class.new(b, @pos.dup, @color, @type)
  end

  def print
    t = ""
    case @type
      when :bishop
        t = @color == :b ? "\u265D ".colorize(:black) : "\u265D "
      when :queen
        t = @color == :b ? "\u265B ".colorize(:black) : "\u265B "
      when :rook
        t = @color == :b ? "\u265C ".colorize(:black) : "\u265C "
    end

    return t
  end

  def moves
    if @type == :queen
      verticals + horizontals + diagonals
    elsif @type == :rook
      horizontals + verticals
    elsif @type == :bishop
      diagonals
    end
  end

  def verticals
    comparators = [[1,0], [-1,0]]
    general_move(comparators)
  end

  def horizontals
    comparators = [[0,1], [0,-1]]
    general_move(comparators)
  end

  def diagonals
    comparators = [[1, -1], [-1, 1], [-1, -1], [1, 1]]
    general_move(comparators)
  end

  def general_move(comparators)
    arr = []
    r,c = pos

    comparators.each do |row, col|
      r += row
      c += col

      loop do
        break if !(r).between?(0,7) || !(c).between?(0,7)
        if @board[[r, c]] == nil
          arr << [r, c]
        else
          arr << [r,c] if @board[[r, c]].color != @color
          break
        end
        r += row
        c += col
      end
      r,c = pos
    end

    arr
  end
end

class SteppingPiece < Piece
  attr_reader :type

  def initialize(board, pos, color, type)
    super(board, pos, color)
    @type = type
  end

  def dup(b)
    self.class.new(b, @pos.dup, @color, @type)
  end

  def moves
    if @type == :king
      king_moves
    elsif @type == :knight
      knight_moves
    end
  end

  def print
    t = ""

    case @type
      when :king
        t = @color == :b ? "\u265A ".colorize(:black) : "\u265A "
      when :knight
        t = @color == :b ? "\u265E ".colorize(:black) : "\u265E "
    end

    return t
  end

  def king_moves
    k_moves = []
    positions = [[0,-1],[0,1],[1,1],[1,-1],[-1,1],[-1,-1],[-1,0],[1,0]]
    k_moves = positions.map{|a,b| [pos[0] + a,pos[1] + b]}.
              select {|a1,b1| a1.between?(0,7) && b1.between?(0,7)}.
              select {|r,c| @board[[r,c]] == nil || @board[[r,c]].color != @color}
    k_moves
  end

  def knight_moves
    k_moves = []
    positions = [[2,-1],[2,1],[-2,1],[-2,-1],[-1,2],[-1,-2],[1,-2],[1,2]]
    k_moves = positions.map{|a,b| [pos[0] + a,pos[1] + b]}.
              select {|a1,b1| a1.between?(0,7) && b1.between?(0,7)}.
              select {|r,c| @board[[r,c]] == nil || @board[[r,c]].color != @color}
    k_moves
  end
end

class Pawn < Piece
  attr_reader :type
  def initialize(board, pos, color)
    super(board, pos, color)
    @type = :pawn
  end

  def dup(b)
    self.class.new(b,@pos.dup,@color)
  end

  def print
    t = ""
    case @color
      when :b
        t = "\u265F ".colorize(:black)
      when :w
        t = "\u265F "
      end
    return t
  end

  def moves
    positions = @move_count == 0 ? [[1,0],[2,0]] : [[1,0]]
    capture_moves = [[1,1],[1,-1]]

    if @color == :w
      positions.map! {|r,c| [r * -1,c * -1]}
      capture_moves.map! {|r,c| [r * -1,c * -1]}
    end

    p_moves = positions.map{|a,b| [pos[0] + a, pos[1] + b]}.
              select {|a1,b1| a1.between?(0,7) && b1.between?(0,7)}.
              select {|r,c| @board[[r,c]] == nil}

    p_moves = p_moves + capture_moves.map{|a,b| [pos[0] + a, pos[1] + b]}.
              select {|a1,b1| a1.between?(0,7) && b1.between?(0,7)}.
              select {|r,c| @board[[r,c]] != nil && @board[[r,c]].color != @color}
    p_moves
  end
end
