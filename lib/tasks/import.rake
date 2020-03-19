require 'net/http'
require 'uri'
require 'json'

task :import => [
  :import_from_sparql] do
end

task :import_from_sparql => :environment do
  puts "importing raw data from sparql query"
  from_date = 2.days.ago.to_date
  to_date = Date.today
  
  uri = URI.parse( "https://api.parliament.uk/sparql" )
  
  request = Net::HTTP::Post.new( uri )
  
  request["Accept"] = "application/sparql-results+json"
  
  request.set_form_data(
    "query" => "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX : <https://id.parliament.uk/schema/>
      select ?Treaty ?Treatyname ?LeadOrg ?Series ?Link ?workPackage ?procStepName ?itemDate where {
        ?Treaty a :Treaty .  
        ?Treaty rdfs:label ?Treatyname .
        OPTIONAL{ ?Treaty :treatyHasLeadGovernmentOrganisation/ rdfs:label ?LeadOrg .} 
        OPTIONAL {?Treaty :treatyHasSeriesMembership/ :seriesItemCitation ?Series.}
        OPTIONAL {?Treaty :workPackagedThingHasWorkPackagedThingWebLink ?Link.}
        ?Treaty :workPackagedThingHasWorkPackage ?workPackage .
        ?workPackage :workPackageHasProcedure/rdfs:label ?proc
        FILTER(?proc IN (\"Treaties subject to the Constitutional Reform and Governance Act 2010\"))
          ?workPackage :workPackageHasBusinessItem/:businessItemHasProcedureStep ?procStep ;
          :workPackageHasBusinessItem ?busItem .
          ?busItem :businessItemHasProcedureStep/rdfs:label ?itemDate2;
          :businessItemDate ?itemDate .
          ?procStep rdfs:label ?procStepName.
        FILTER(?procStepName IN (\"Laid before the House of Commons\"))
        FILTER(?itemDate2 IN (\"Laid before the House of Commons\"))
        FILTER ( str(?itemDate) >= '#{from_date}' && str(?itemDate) <= '#{to_date}')
      }
    ",
  )

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  
  json = JSON( response.body )
  puts "found #{json['results']['bindings'].size} instruments"
  json['results']['bindings'].each do |treaty_json|
      puts treaty_json["Treatyname"]["value"].strip
    instrument = Instrument.where( instrument_uri: treaty_json['Treaty']['value'] ).first
    unless instrument
      instrument = Instrument.new
      instrument.title = treaty_json["Treatyname"]["value"].strip
      instrument.lead_organisation = treaty_json["LeadOrg"]["value"].strip
      instrument.series = treaty_json["Series"]["value"].strip
      instrument.date_laid = treaty_json["itemDate"]["value"].strip
      instrument.instrument_uri = treaty_json['Treaty']['value']
      instrument.work_package_uri = treaty_json['workPackage']['value']
      instrument.tna_uri = treaty_json['Link']['value']
      instrument.save
    end
  end
end