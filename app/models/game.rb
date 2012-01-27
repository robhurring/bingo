class Game
  include Mongoid::Document
  include Mongoid::Timestamps

  MinimumWords = 9

  field :name, type: String
  field :token, type: String
  field :words, type: Array
  field :active, type: Boolean, default: true

  attr_accessible :name, :words
  embeds_many :cards

  validates :name, presence: true, length: {within: 3..150}
  validates :token, presence: true, uniqueness: true

  validate :must_have_enough_words
  before_validation :set_token

  def self.generate_token(seed = nil)
    (seed || Time.now).to_i.to_s(16)
  end

  def words=(words)
    words = Array(words.split("\n")) unless words.is_a?(Array)
    cleaned_words = words \
      .map(&:strip) \
      .map(&:downcase) \
      .map{ |word| word.gsub /[^\w]/, '' } \
      .uniq
      .reject{ |word| word.blank? }[0...MinimumWords]

    write_attribute(:words, cleaned_words)
  end

  def won?
  end

  def winner
  end

private

  def set_token
    write_attribute :token, self.class.generate_token
  end

  def must_be_perfect_square
    unless (words.size.to_i ** 0.5 == Math.sqrt(words.size))
      errors.add(:words, 'The number of words you provided wasn\'t a perfect square (We can\'t generate a proper board like that!)')
    end
  end

  def must_have_enough_words
    if words.size < MinimumWords
      errors.add(:words, 'You did\'t provide enough words! For a game we need %d words.' % MinimumWords)
    end
  end
end