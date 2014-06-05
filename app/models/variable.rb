class Variable
  attr_accessor :surfaceform, :offset, :class, :uri, :value, :literal_type, :score
  attr_reader :type
  
  def type=(type)
    @type = type
    if type.casecmp('number')==0 || type.casecmp('date')==0 || type.casecmp('string')==0
      @literal_type = type
      @type = 'literal'
    end
  end
  
  def literal?
    (@type||'').casecmp('literal') == 0
  end
  
  def property?
    (@type||'').casecmp('rdf:Property') == 0
  end
  
  def resource?
    (@type||'').casecmp('rdf:Resource') == 0
  end
end