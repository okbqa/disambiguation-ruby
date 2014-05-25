def Slot
  attr_accessor :s, :p, :o
  
  def self.parse_many (inputs)
    inputs.map{|x| parse(x)}
  end
  
  def self.parse (input)
    slot = Slot.new
    %w[s p o].each do |attr|
      value = input[attr]
    end
    slot
  end
end