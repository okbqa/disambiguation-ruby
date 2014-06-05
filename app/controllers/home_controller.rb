class HomeController < ApplicationController
  respond_to :json
  def request
    text = params['json']
    json = JSON.parse(text)
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
      
      property.uri = Property.find(subject, property.verbalization, object, language).first[:uri]
    end
    
    
    # format response
    score = 0.5
    
    response_hash = {
      question: json['query'],
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
    
    respond_with response_hash.to_json
  end
end