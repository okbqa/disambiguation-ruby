class Query
  attr_accessor :relations
  
  def initialize
    @relations = []
  end
  
  def self.parse(q)
    query = Query.new
    where = q[/{.*}/]
    query.relations = where.split(/[\.{}]/).
                       select{|x| x.strip.length>0}.
                       map{|x| Relation.parse x}
    query
  end
end