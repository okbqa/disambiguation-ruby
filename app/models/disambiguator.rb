class Disambiguator
  def self.disambiguate(json)
    question = json['question']
    language = json['language']
  
    # parse inputs
    slots = Slot.parse_many json['slots']
    query = Query.parse json['pseudoquery']
    
    vars = {}
    slots.each do |slot|
      vars[slot.s] ||= Variable.new
      if "is".casecmp(slot.p)==0
        vars[slot.s].type = slot.o
      elsif "verbalization".casecmp(slot.p)==0
        vars[slot.s].surfaceform = slot.o
      end
    end
    
    resource_vars = vars.values.select{|x| x.resource?}
    property_vars = vars.values.select{|x| x.property?}

        
    # disambiguate resources with dbpedia spotlight
    resource_verbalizations = resource_vars.collect{|x| x.surfaceform}
    resources = Resource.find(question, resource_verbalizations)
    verbalization_map = Hash[resource_verbalizations.zip resource_vars]
    
    resources.each do |resource|
      var = verbalization_map[resource['@surfaceForm']]
      var.score ||= 0
      if var.score < resource['@similarityScore'].to_f
        var.score = resource['@similarityScore'].to_f
        var.offset = resource['@offset'].to_i
        var.uri = resource['@URI']
        var.class = resource['@types'].split(',').first
      end
    end

    # disambiguate properties
    query.relations.each do |relation|
      subject = vars[relation.s]
      property = vars[relation.p]
      object = vars[relation.o]
      
      property_candidates = Property.find(subject, property.surfaceform, object, language)
      best_candidate = property_candidates.first
      property.uri = best_candidate[:uri]
      property.score = best_candidate[:score]
      #property.uri = Property.find(subject, property.surfaceform, object, language).first[:uri]
    end
    
    
    # score is minimum value among best score for each entity and property
    resource_score = resource_vars.map{|x| x.score}.min
    property_score = property_vars.map{|x| x.score}.min
    score = [resource_score, property_score].min
    
    # format response
    response_hash = {
      question: json['question'],
      ned: [{
        score: score,
        entities: [
          resource_vars.map{|x| {
            var: x.surfaceform,
            value: x.uri,
            type: x.class,
            score: x.score
          }}
        ],
        properties: [
          property_vars.map{|x| {
            var: x.surfaceform,
            value: x.uri,
            score: x.score
          }}
        ]
      }]
    }
  end
end