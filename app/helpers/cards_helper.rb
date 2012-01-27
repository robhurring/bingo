module CardsHelper
  def hash(word)
    Digest::MD5.hexdigest(word)
  end
end
