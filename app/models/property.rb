class Property

  # subject: a rdf:resource
    # uri : a uri, required
  # object : a rdf:resource or a literal
    # uri : a uri, not required
    # type : one of [rdf:resource, number, *xsd:literal_types]
  def self.find(subject, verbalization, object, language)
    lang_filter = " filter(langMatches(lang(?label), \"#{language}\"))"    
    subject_var = '?s'
    object_var = '?o'
    
    # subject is a known entity
    if subject.uri
      subject_var = '<' + subject.uri + '>'
    end
    #object is a known entity
    if object.uri
      object_var = '<' + object.uri + '>'
    #object is of a known literal type
    elsif object.literal?
      types = expand_literal_type object.literal_type
      type_filters = types.map{|x| "(datatype(?o) = #{x})"}
      type_filter = "filter(#{type_filters.join(' || ')})"
    end
    
    sparql = "
      select * where {
        #{subject_var} ?p #{object_var}.
        ?p rdfs:label ?label .
        #{type_filter}
        #{lang_filter}
      }
    "
    
    results = client.query sparql
    
    scored_results = results.map {|result|
      {
        uri: result.p.value,
        label: result.label.value,
        score: score_label(result.label.value, verbalization)
      }
    }
    
    scored_results.sort_by {|h| h[:score]}.reverse
  end

  def self.client
    @client ||= SPARQL::Client.new 'http://live.dbpedia.org/sparql'
  end
  
  def self.expand_literal_type(type)
    if type == 'number'
      %w[xsd:decimal xsd:number xsd:integer xsd:int]
    end
  end
  
  def self.score_label(str1, str2)
    (1.0 - Levenshtein.normalized_distance(str1, str2))
  end

end

