class Relation
  attr_accessor :s, :p, :o
  
  def self.parse(r)
    vars = r.split(/\s/).select{|x| x.strip.length > 0}
    return from_vars(vars)
  end
  
  def self.from_vars(vars)
    return nil if vars.length != 3
    relation = Relation.new
    relation.s = vars[0]
    relation.p = vars[1]
    relation.o = vars[2]
    relation
  end
end