require 'sinatra'
require 'json'
require 'httparty'
require 'dotenv/load'

post '/payload' do
  event_type = request.env['HTTP_X_GITHUB_EVENT']
  request.body.rewind
  payload = JSON.parse(request.body.read)
  # pp payload

  case event_type
  when "issues"
    process_issues(payload)
  else
    puts "Oooh, something new from GitHub: #{event_type}"
  end
end

def process_issues(payload)
  url = ENV['SLACK_WEBHOOK_URL']
  if payload['action'] == 'labeled'
    HTTParty.post(
      url,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        text: 'Label ' + payload['label']['name'] + ' was added to issue ' + '<' + payload['issue']['html_url'] + '|' + payload['issue']['number'].to_s + '>'
      }.to_json
    )
  end
end

