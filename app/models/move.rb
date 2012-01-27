class Move
  def initialize(name, word, found = true)
    @name, @word, @found = name, word, found
    @hash = Digest::MD5.hexdigest(word)
  end

  def to_h
    {
      name: @name,
      found: @found,
      word: @word,
      hash: @hash
    }
  end
end