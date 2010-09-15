require 'digest/sha1'

class Game < ActiveRecord::Base
  MinimumWords = 25
  
  attr_accessible :name, :words
  
  serialize :words, Array
  
  validates_presence_of :name, :message => 'Name cannot be blank!'
  validates_length_of :name, :within => 3..150, :on => :create, :message => "Name must be between 3 - 150 characters"
  validates_presence_of :token
  validates_uniqueness_of :token
  validates_presence_of :words, :message => 'You must enter some words to use!'
  
  has_many :cards, :dependent => :destroy
  
  before_validation :set_defaults
  validate :must_have_enough_words
  
  def self.generate_token
    Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
  end

  def name=(name)
    write_attribute(:name, Sanitize.clean(name))
  end

  def words=(words)
    words = Array(words.split("\n")) unless words.is_a?(Array)
    cleaned_words = words \
      .map(&:strip) \
      .map(&:downcase) \
      .map{ |word| Sanitize.clean(word) } \
      .map{ |word| word.gsub /[^\w]/, '' } \
      .uniq.reject{ |word| word.blank? }
    write_attribute(:words, cleaned_words)
  end

  def won?
    !won_at.blank?
  end
  
private
  
  # TODO: implement this in the validations once we allow dynamic boards
  def must_be_perfect_square
    unless (words.size.to_i ** 0.5 == Math.sqrt(words.size))
      errors.add(:words, 'The number of words you provided wasn\'t a perfect square (We can\'t generate a proper board like that!)')
    end
  end

  def must_have_enough_words
    if words.size >= MinimumWords
      self.words = words[0...MinimumWords]
    elsif words.size < MinimumWords
      errors.add(:words, 'You did\'t provide enough words! For a game we need %d words.' % MinimumWords)
    end
  end
  
  def set_defaults
    self.words = [] if self.words.blank?
    self.token = self.class.generate_token if self.token.blank?
    self.messages = ''
  end
end