class Relation
  attr_accessor :s, :p, :o
  
  def self.parse(r)
    pieces = r.split(/\s/).select{|x| x.strip.length > 0}
    if pieces.length == 3
      relation = Relation.new
      relation.s = pieces[0]
      relation.p = pieces[1]
      relation.o = pieces[2]
      return relation
    end
  end
end