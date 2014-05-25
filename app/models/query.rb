class Query
  attr_accessor :relations
  
  def initialize
    @relations = []
  end
  
  def self.parse(q)
    query = Query.new
    where = q[/{.*}/]
    @relations = where.split(/[\.{}]/).map{|x| Relation.parse x}
  end
end