class Resource
  def self.find(question, verbalizations)
    builder = Nokogiri::XML::Builder.new do 
      annotation(text: question) {
        verbalizations.each do |verbalization|
          surfaceForm(name: verbalization, offset: question.index(verbalization))
        end
      }
    end
    
    text = builder.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)
    
    spotlight_response = RestClient.get 'http://spotlight.dbpedia.org/rest/disambiguate/?spotter=SpotXmlParser&text=' + URI::encode(text), accept: :json
    (JSON.parse spotlight_response)['Resources']
  end
end