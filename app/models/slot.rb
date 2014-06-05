class Slot
  attr_accessor :s, :p, :o
  
  def self.parse_many (inputs)
    inputs.map{|x| parse(x)}
  end
  
  def self.parse (input)
    slot = Slot.new
    slot.s = input['s']
    slot.p = input['p']
    slot.o = input['o']
    slot
  end
end