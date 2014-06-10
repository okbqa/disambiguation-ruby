class Query
  attr_accessor :relations
  
  def initialize
    @relations = []
  end
  
  def self.parse(q)
    query = Query.new
    q.gsub! "\n", " "
    where = q[/{.*}/].gsub('{', '').gsub('}', '')
    
    filter = where.index('FILTER')
    if filter
      where = where[0...filter]
    end
    
    vars = where.split.map{|x| x.strip}.select{|x| !['.', '', 'UNION'].include? x}.map{|x| x.end_with?('.') ? x[0..-2] : x}
    if vars.length % 3 != 0
      puts vars
      raise "Couldn't identify triplets!"
    else
      query.relations = vars.each_slice(3).to_a.map{|x| Relation.from_vars(x)}
    end
=begin    
    query.relations = where.split.
                       select{|x| x.strip.length>0}.
                       map{|x| Relation.parse x}.
                       select{|x| !x.nil?}
=end                       
    query
  end
end