require 'airrecord'


key = "keytest"
airbase_id = "apptest"
table_name = "emp1"
puts "== Airtable magic."
Airrecord.api_key = "keytest"
Emp1 = Airrecord.table(key, airbase_id, table_name)

Emp1.all.each do |record|
    puts "#{record.id}: #{record["Role"]}"
end

temp = Emp1.create("Username" => "umut", "Role" => "software eng", "Geolocation" => "Ankara", "ProfileIMG_URL" => "url1", "ProfileURL" => "url2")