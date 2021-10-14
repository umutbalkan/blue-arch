require 'rubygems'
require 'mechanize'

# LinkedIn env. variables
my_id = 'X'
my_pass= 'Y'

agent = Mechanize.new
agent.follow_meta_refresh = true # LinkedIn refreshes after login
agent.user_agent_alias = "Windows Edge" #fake user-agent
agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#p Mechanize::AGENT_ALIASES

page = agent.get('https://www.linkedin.com/')
#pp page

signIn_form = page.forms.first # => Mechanize::Form
signIn_form.fields.each { |f| puts f.name } # print
signIn_form['session_key'] = my_id
signIn_form['session_password'] = my_pass
page = agent.submit(signIn_form)

page = agent.get('https://www.linkedin.com/company/copper-inc/')
puts page.body
