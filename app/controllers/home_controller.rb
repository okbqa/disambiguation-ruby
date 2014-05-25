class HomeController < ApplicationController
  def request
  
    # parse inputs
    slots = Slot.parse_many params['slots']
    query = Query.parse params['query']
    
    vars = {}
    slots.each do |slot|
      vars[slot.s] ||= Variable.new
      if slot.p.casecmp('is')==0
        vars[slot.s].type = slot.o
      elsif slot.p.casecmp('verbalization')==0
        vars[slot.s].surfaceform = slot.o
    end
    
    resource_vars = vars.values.filter{|x| x.resource?}
    property_vars = vars.values.filter{|x| x.property?}
    
    # disambiguate resources with dbpedia spotlight
    resource_verbalizations = resource_vars.collect({|x| x.surfaceform}
    resources = Resource.find(question, resource_verbalizations)['Resource']
    verbalization_map = Hash[resource_verbalizations.zip resource_vars]
    
    resources.each do |resource|
      var = vars[resource['@surfaceForm']]
      var.score ||= 0
      if var.score < resource['@similarityScore'].to_f
        var.score = resource['@similarityScore'].to_f
        var.offset = resource['@offset'].to_i
        var.uri = resource['@URI']
        var.class = resource['@types'].split(',').first
      end
    end
    
    # disambiguate properties
    properties = {}
    query.relations.each do |relation|
      subject = vars.select{|x| x.surfaceform == relation.s}.first
      property = vars.select{|x| x.surfaceform == relation.p}.first
      object = vars.select{|x| x.surfaceform == relation.o}.first
      
      property.uri = Property.find(subject, property, object).first[:uri]
    end
    
    
    # format response
    score = 0.5
    
    response = {
      question: params['query'],
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
    
    respond_with response.to_json
  end
end