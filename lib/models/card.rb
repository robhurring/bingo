class Card < ActiveRecord::Base  
  belongs_to :game
  
  serialize :words, Array
  serialize :found, Array
  
  validates_presence_of :name
  validates_presence_of :words
  
  before_validation :set_defaults
  before_create :shuffle
     
  def shuffle
    write_attribute(:words, words.shuffle)
  end
    
  def matrix
    @matrix ||= words.in_groups_of(size)
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
  
  def set_defaults
    write_attribute(:words, game.words) if self.words.blank?
    write_attribute(:found, []) if self.found.blank?
  end
end