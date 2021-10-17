# Require the gems we want to use
require 'watir'
require './Employee.rb'

# Initialize the Browser
browser = Watir::Browser.new :chrome, headless: true

#browser.send_keys [:command, :subtract]*3

# Navigate to Page
browser.goto 'https://www.linkedin.com'

# Fill out Input Field
bot_uname = "USERNAME"
bot_password = "PASSWORD"
browser.text_field(id: 'session_key').set(bot_uname)
browser.text_field(id: 'session_password').set(bot_password)
puts "== Signing in."
#ifield_uname = browser.text_field(id: 'session_key')
#ifield_pass = browser.text_field(id: 'session_password')

=begin
if ifield_uname.exists?
    ifield_uname.set("yavaji1832@wii999.com")
else
    puts "ERR::Input Field::Username Does Not Exist"
end

if ifield_pass.exists?
    ifield_pass.set("metent2fmtr")
else
    puts "ERR::Input Field::Password Does Not Exist"
end
=end

# Click sign-in
button_login = browser.button(class: 'sign-in-form__submit-button')
button_login.click
puts "== Loading the Company Page"
company1 = "https://www.linkedin.com/company/keyyazilimcom/"
browser.goto(company1)

# Retrieve Company info
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

puts "*====== ======*"
puts "* #{company_name} *"
puts "#{company_location} - #{company_webURL}"
puts "*====== ======*"
# Go to employees 
browser.span(class: "t-black--light").click
browser.wait_until { |b| b.title == "Search | LinkedIn"}
browser.send_keys :page_down
browser.wait_until(timeout: 1)
# Scroll down a bit, necessary because of dynamic loading.
browser.send_keys :space
browser.wait_until(timeout: 2)
browser.send_keys :page_down
browser.send_keys :space

puts "== Getting ready to scrap Employees"
# zoom-out
browser.execute_script("document.body.style.zoom='75%'")
browser.wait_until(timeout: 1)
# Get total # of pages
pages = browser.div(class: "artdeco-pagination").ul(class: "artdeco-pagination__pages")
browser.wait_until(pages.exists?)
max_pages = pages[pages.length-1].text
max_pages = max_pages.to_i


# Next Page Button
#next_page = browser.button(class: "artdeco-pagination__button--next")

# This block prints:
# Name
# Title
# Location
# URL (Optional): Since private profiles do not have a unique link (or any link) it is optional.

temp_counter = 0
cur_url = browser.url
cur_page = 1
browser.goto(cur_url + "&page=#{cur_page}")
puts "== Starting..."
while cur_page <= max_pages
    puts "== Scrapping Page #{cur_page}/#{max_pages}"
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
        puts roles[itr].text + "-" + locs[itr].text
        #puts "Profile Picture: " + pp_arr[itr]
        #puts "Profile URL: " + user_urls[itr].href
        itr = itr + 1
    end

    # Next Page Button
    #next_page = browser.button(class: "artdeco-pagination__button--next")
    #browser.wait_until { next_page.exists? }
    #cur_page += 1
    #if !next_page.disabled?
    #    next_page.click
    #end
    browser.wait_until(timeout: 0.5)
    temp_counter += curr_record_amount
    cur_page = cur_page + 1
end

puts "== End of Employee list. Total of #{temp_counter} employees."