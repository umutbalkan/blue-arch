# Require the gems we want to use
require 'watir'
require 'airrecord'

airbase_id = "app_AIRTABLE_BASEID"
Airrecord.api_key = "key_APIKEY"
bot_uname = "UNAME"
bot_password = "PASS"
table_employee = "emp1"
table_company = "comp1"

Selenium::WebDriver.logger.level = :error
# Input
if ARGV.length != 1
    puts "Usage: ruby keystone.rb <linkedin-URL-of-Company>"
    exit(true)
end


# Initialize the Browser
browser = Watir::Browser.new :chrome, headless: true

# Navigate to Page
browser.goto 'https://www.linkedin.com'

# Fill out Input Field
puts "== Signing in."
ifield_uname = browser.text_field(id: 'session_key')
ifield_pass = browser.text_field(id: 'session_password')

if ifield_uname.exists?
    ifield_uname.set(bot_uname)
else
    puts "ERR::Input Field::Username Does Not Exist"
end

if ifield_pass.exists?
    ifield_pass.set(bot_password)
else
    puts "ERR::Input Field::Password Does Not Exist"
end

# Click sign-in
button_login = browser.button(class: 'sign-in-form__submit-button')
button_login.click

puts "== Loading the Company Page"
company_profile = ARGV[0]
browser.goto(company_profile)

# Retrieve Company info
Comp1 = Airrecord.table(Airrecord.api_key, airbase_id, table_company)
company_logo_url = browser.img(class: "org-top-card-primary-content__logo").src
company_name = browser.h1.text
company_info = browser.divs(class: "org-top-card-summary-info-list__info-item")
company_field = ""
company_location = ""
if (company_info.length > 2)
    company_field = company_info[0].text
    company_location = company_info[1].text
end
company_webURL = browser.link(class: "org-top-card-primary-actions__action").href
t_comp = Comp1.create(
        "CompanyName"       => company_name, 
        "CompanyField"      => company_field, 
        "CompanyLocation"   => company_location, 
        "CompanyWebURL"     => company_webURL, 
        "CompanyLogo"       => company_logo_url,
        "CompanyProfile"    => company_profile)

puts "* #{company_name} *"
puts "HQ: #{company_location} - #{company_webURL}"

# Go to employees page
browser.span(class: "t-black--light").click 
browser.wait_until { |b| b.title == "Search | LinkedIn"}
browser.send_keys :page_down
browser.wait_until(timeout: 1)

# Scroll down a bit, necessary because of dynamic loading.
browser.send_keys :space
browser.wait_until(timeout: 1)
browser.send_keys :page_down
browser.send_keys :space

puts "== Getting ready to scrap Employees"
browser.execute_script("document.body.style.zoom='75%'") # zoom-out
browser.wait_until(timeout: 1)

# Get total # of pages
pages = browser.div(class: "artdeco-pagination").ul(class: "artdeco-pagination__pages")
browser.wait_until(pages.exists?)
max_pages = pages[pages.length-1].text
max_pages = max_pages.to_i


# This block prints:
# Name
# Title
# Location
# URL (Optional): Since private profiles do not have a unique link (or any link).

temp_counter = 0
cur_url = browser.url
cur_page = 1
browser.goto(cur_url + "&page=#{cur_page}")
Emp1 = Airrecord.table(Airrecord.api_key, airbase_id, table_employee)
puts "== Starting..."
while cur_page <= max_pages
    puts "== Scraping Page #{cur_page}/#{max_pages}"
    browser.goto(cur_url + "&page=#{cur_page}")
    # scroll down
    browser.send_keys :page_down
    browser.wait_until(timeout: 0.5)


    pp_arr = Array.new() # User Profile Picture URLs
    names = browser.spans(class: ["t-16"]) # User Full-Name, or LinkedIn Member if private
    roles = browser.divs(class: "entity-result__primary-subtitle") # User Role
    locs = browser.divs(class: "entity-result__secondary-subtitle") # User Geolocation
    user_urls = browser.links(class: "app-aware-link") # User URL, remember length is x2 then normal. 
    user_imgs = browser.divs(class: "entity-result__image") # User Profile Pictures,
    
    browser.wait_until { names.length > 0 }
    browser.wait_until { user_imgs.length > 0}
    user_imgs.each do |uvar|
        if uvar.img.exists?
            pp_arr.push(uvar.img.src)
        else
            pp_arr.push("EMPTY-PICTURE")
        end
    end

    # Get # of records of current page
    curr_record_amount = names.length
    itr = 0
    while itr < curr_record_amount

        # Re-format names for proper records.
        clean_name = names[itr].text
        if !clean_name.index("View").nil?
            bs_ind = clean_name.index("View")
            clean_name = clean_name.slice(0, bs_ind - 1)
        end     

        # Re-format profile urls for proper records.
        clean_url = user_urls[itr*2].href
        clean_url = clean_url.slice(0,56)
        if clean_url == "https://www.linkedin.com/search/results/people/headless?"
            clean_url = "EMPTY-URL"
        else
            clean_url = user_urls[itr*2].href
        end

        puts "#{itr+1}/#{curr_record_amount} " + clean_name + "-" + locs[itr].text

        temp = Emp1.create(
        "Username"       => clean_name, 
        "Role"           => roles[itr].text, 
        "Geolocation"    => locs[itr].text, 
        "ProfileIMG_URL" => pp_arr[itr], 
        "ProfileURL"     => clean_url,
        "CompanyURL"     => company_profile)

        itr = itr + 1
    end



    browser.wait_until(timeout: 0.5)
    temp_counter += curr_record_amount
    cur_page = cur_page + 1
end

puts "== End of Employee list. Total of #{temp_counter} employees."