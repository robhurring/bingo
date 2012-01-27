class Card
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :words, type: Array, default: []
  field :found, type: Array, default: []
  field :won, type: Boolean, default: false
  field :won_at, type: DateTime

  attr_accessible :name
  embedded_in :game

  validates :name, presence: true

  before_create :shuffle

  def shuffle
    write_attribute(:words, game.words.shuffle)
  end

  def matrix
    @matrix ||= words.in_groups_of(size)
  end

  def hashed_matrix
    matrix.map do |row|
      row.map{ |word| {word: word, hash: Digest::MD5.hexdigest(word)} }
    end
  end

  def size
    @size ||= Math.sqrt(words.size).to_i
  end

  def at(row = 0, column = 0)
    matrix[row][column]
  end

  def has?(row = 0, column = 0)
    found.include? at(row, column)
  end

  def has_word?(word)
    found.include?(word)
  end

  def found!(row = 0, column = 0)
    word = at(row, column)
    found << word unless has_word?(word)
  end

  def unfind!(row = 0, column = 0)
    word = at(row, column)
    found.delete(word) if has_word?(word)
  end

  def bingo?
    return false if found.size < size

    size.times do |i|
      return true if row(i).all?{ |word| has_word?(word) }
      return true if column(i).to_a.all?{ |word| has_word?(word) }
    end

    diagonal(0).all?{ |word| has_word?(word) } || diagonal(size - 1).all?{ |word| has_word?(word) }
  end

  def row(i)
    matrix[i]
  end

  def column(i)
    (0...size).collect{ |n| matrix[n][i] }
  end

  def diagonal(start)
    m = start.zero? ? matrix : matrix.map(&:reverse)
    (0...size).collect{ |i| m[i][i] }
  end

  def as_json(options = nil)
    {
      id: id,
      game_id: game.id,
      name: name,
      matrix: hashed_matrix
    }
  end
end