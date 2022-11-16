# frozen_string_literal: true

module OrderedStringService
  # defaults
  TOKEN_DELIMITER = '~'

  # convert a serialized array to a normal array of values
  #
  def self.deserialize(arr)
    return [] if arr.blank?

    OrderedStringService.to_array(arr)
  end

  #
  # serialize a normal array of values to an array of ordered values
  #
  def self.serialize(arr)
    return [] if arr.blank?

    res = []
    arr.each_with_index do |val, ix|
      res << OrderedStringService.encode(ix, val)
    end

    res
  end

  #
  # deserialize a serialized array of values preservoing the original order
  #
  def self.to_array(arr)
    res = []
    OrderedStringService.sort(arr).each do |val|
      res << OrderedStringService.get_value(val)
    end
    res
  end

  #
  # sort an array of serialized values using the index token to determine the order
  #
  def self.sort(arr)
    # Hack to force a stable sort; see https://stackoverflow.com/questions/15442298/is-sort-in-ruby-stable
    n = 0
    arr.sort_by { |val| [OrderedStringService.get_index(val), n += 1] }
  end

  #
  # encode an index and a value into a composite field
  #
  def self.encode(index, val)
    "#{index}#{TOKEN_DELIMITER}#{val}"
  end

  #
  # extract the index attribute from the serialized value; return index '0' if the
  # field cannot be parsed correctly
  #
  def self.get_index(val)
    tokens = val.split(TOKEN_DELIMITER, 2)
    return tokens[0] if tokens.length == 2

    '0'
  end

  #
  # extract the value attribute from the serialized value; return the entire value if the
  # field cannot be parsed correctly
  #
  def self.get_value(val)
    tokens = val.split(TOKEN_DELIMITER, 2)
    return tokens[1] if tokens.length == 2

    val
  end

  #
  # convert an ActiveTriples::Relation to a standard array (for debugging)
  #
  def self.relation_to_array(arr)
    arr.map(&:to_s)
  end
end
