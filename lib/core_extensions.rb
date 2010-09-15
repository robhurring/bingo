class Array
  # from rails
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

class Hash
  # from rails
  def stringify_keys
   inject({}) do |options, (key, value)|
     options[key.to_s] = value
     options
    end
  end
  
  def to_attributes
    stringify_keys.inject([]) do |m, pair|
      m << "%s='%s'" % pair
    end.join(' ')
  end
  
  # from merb
  def to_params
    params = ''
    stack = []

    each do |k, v|
      if v.is_a?(Hash)
        stack << [k,v]
      else
        params << "#{k}=#{v}&"
      end
    end

    stack.each do |parent, hash|
      hash.each do |k, v|
        if v.is_a?(Hash)
          stack << ["#{parent}[#{k}]", v]
        else
          params << "#{parent}[#{k}]=#{v}&"
        end
      end
    end

    params.chop! # trailing &
    params
  end
end