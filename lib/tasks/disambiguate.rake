namespace :disambiguate do
  desc "Run on training set"
  task train: :environment do
    # somewhat hacky in preparing input for the disambiguation module
    # uses a priori information + answers to questions to construct inputs
  
    f = File.open 'public/qald-4_multilingual_test_withanswers.xml'
    doc = Nokogiri::XML f
    f.close
    
    slots = []
    untyped_slots = []
    literal_map = {'?date' => 'date', '?n' => 'number', '?num' => 'number', '?string' => 'string', '?score' => 'number', '?b' => 'number', '?s' => 'number'}
    
    doc.css('question').each do |question|
      query = question.css('string[lang="en"]').first.text
      sparql = question.css('query').first.text.gsub("\n", " ")
      
      next if sparql.strip == "OUT OF SCOPE"
      sparql = sparql[sparql.index(/SELECT|ASK/)..-1]
      
      keywords = question.css('keywords[lang="en"]').text.split(/[\s,]/)

      parsed_query = Query.parse(sparql)

      vars = []
      
      parsed_query.relations.each do |relation|
        %w[s p o].each do |part|
          vars << relation.send(part)
        end
      end
      
      relation_var = '?relation_var_a'
      resource_var = '?resource_var_a'
      
      vars.each do |var|
        if var =~ /^yago:|res:|\?city|\?person|\?country|\?child|\?x|\?f/ || var == '?uri' || var == '?p'
          slots << [var, 'is', 'rdf:Resource']
        elsif var =~ /^[dbo:|foaf:|dbp:|rdf:|rdfs:]/
          slots << [var, 'is', 'rdf:Property']
        elsif literal_map.keys.include? var
          slots << [var, 'is', literal_map[var]]
        elsif var.start_with?('<') && var.end_with?('>') 
          #it's a resource literal, do nothing
        else
          untyped_slots << var
        end
      end
      
      slots.each do |slot|
        if is_uri(slot)
        
        end
      end
    end
  end

  desc "Run on tool evaluation set"
  task evaluate: :environment do
  end

end
