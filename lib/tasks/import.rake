require 'net/http'
require 'uri'
require 'json'

task :import => [
  :import_from_sparql] do
end

task :import_from_sparql => :environment do
  puts "importing raw data from sparql query"
  today = Date.today
  uri = URI.parse( sparql_uri( today ) )
  
  request = Net::HTTP::Get.new( uri )
  request["Accept"] = "application/sparql-results+json"
  req_options = {
    use_ssl: uri.scheme == "https",
  }
  
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
  json = JSON( response.body )
  json['results']['bindings'].each do |treaty_json|
    instrument = Instrument.where( instrument_uri: treaty_json['Treaty']['value'] ).first
    unless instrument
      puts "creating instrument"
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




def sparql_uri( latest_date_laid )
    "https://api.parliament.uk/sparql?query=PREFIX%20rdfs%3A%20%3Chttp%3A%2F%2Fwww.w3.org%2F2000%2F01%2Frdf-schema%23%3E%0APREFIX%20%3A%20%3Chttps%3A%2F%2Fid.parliament.uk%2Fschema%2F%3E%0Aselect%20%3FTreaty%20%3FTreatyname%20%3FLeadOrg%20%3FSeries%20%3FLink%20%3FworkPackage%20%3FprocStepName%20%3FitemDate%20where%20%7B%0A%20%3FTreaty%20a%20%3ATreaty%20.%20%20%0A%20%20%20%20%20%3FTreaty%20rdfs%3Alabel%20%3FTreatyname%20.%0A%20%20OPTIONAL%7B%20%3FTreaty%20%3AtreatyHasLeadGovernmentOrganisation%2F%20rdfs%3Alabel%20%3FLeadOrg%20.%7D%20%0A%20%20OPTIONAL%20%7B%3FTreaty%20%3AtreatyHasSeriesMembership%2F%20%3AseriesItemCitation%20%3FSeries.%7D%0A%20%20OPTIONAL%20%7B%3FTreaty%20%3AworkPackagedThingHasWorkPackagedThingWebLink%20%3FLink.%7D%0A%09%3FTreaty%20%3AworkPackagedThingHasWorkPackage%20%3FworkPackage%20.%0A%20%20%09%3FworkPackage%20%3AworkPackageHasProcedure%2Frdfs%3Alabel%20%3Fproc%0A%20%20FILTER(%3Fproc%20IN%20(%22Treaties%20subject%20to%20the%20Constitutional%20Reform%20and%20Governance%20Act%202010%22))%0A%20%3FworkPackage%20%3AworkPackageHasBusinessItem%2F%3AbusinessItemHasProcedureStep%20%3FprocStep%20%3B%0A%20%20%20%20%20%20%20%20%20%20%20%3AworkPackageHasBusinessItem%20%3FbusItem%20.%0A%20%20%3FbusItem%20%3AbusinessItemHasProcedureStep%2Frdfs%3Alabel%20%3FitemDate2%3B%0A%20%20%20%20%20%20%20%20%20%20%20%3AbusinessItemDate%20%3FitemDate%20.%0A%20%20%3FprocStep%20rdfs%3Alabel%20%3FprocStepName.%0A%20%20%20%20%0A%20%20FILTER(%3FprocStepName%20IN%20(%22Laid%20before%20the%20House%20of%20Commons%22))%0A%20%20FILTER(%3FitemDate2%20IN%20(%22Laid%20before%20the%20House%20of%20Commons%22))%0A%20%20FILTER%20(%20str(%3FitemDate)%20%3E%20'#{latest_date_laid}')%0A%20%20%20%7D%0A"
end