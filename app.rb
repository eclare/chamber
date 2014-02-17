# coding: utf-8
require "sinatra"
require "rest_client"
require "slack-notify"
require "fileutils"
require "erb"

set :show_exceptions, false

use Rack::Logger

SLACK_TEAM         = ENV["SLACK_TEAM"]
SLACK_ACCESS_TOKEN = ENV["SLACK_ACCESS_TOKEN"]
SLACK_CHANNEL      = ENV["SLACK_CHANNEL"]
SLACK_USERNAME     = ENV["SLACK_USERNAME"]

AZURE_CLIENT_ID     = ENV["AZURE_CLIENT_ID"]
AZURE_CLIENT_SECRET = ENV["AZURE_CLIENT_SECRET"]

STORES_FILE             = "./data/words.txt"
AZURE_ACCESS_TOKEN_FILE = "./data/azure_access_token.txt"

FileUtils.touch STORES_FILE             unless File.exist? STORES_FILE
FileUtils.touch AZURE_ACCESS_TOKEN_FILE unless File.exist? AZURE_ACCESS_TOKEN_FILE

helpers do
    def logger
      request.logger
    end

  def slack_client
    @client ||= SlackNotify::Client.new(SLACK_TEAM, SLACK_ACCESS_TOKEN, {
      channel: SLACK_CHANNEL,
      username: SLACK_USERNAME,
    })
  end

  def get_microsoft_access_token
    timestamp, token = File.read(AZURE_ACCESS_TOKEN_FILE).split(",")

    now = Time.now
    if timestamp && (now.to_i - timestamp.to_i < 590)
      return token
    end

    payloads = {
      "grant_type"    => "client_credentials",
      "client_id"     => AZURE_CLIENT_ID,
      "client_secret" => AZURE_CLIENT_SECRET,
      "scope"         => "http://api.microsofttranslator.com",
    }
    url = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"

    res = RestClient.post(url, payloads)

    token = JSON.parse(res)["access_token"]
    File.write(AZURE_ACCESS_TOKEN_FILE, "#{Time.now.to_i},#{token}")
    token
  end

  def translate(text, way)
    url = "http://api.microsofttranslator.com/v2/Http.svc/Translate?from=#{way[:from]}&to=#{way[:to]}&text=#{ERB::Util.url_encode(text)}"
    token = get_microsoft_access_token
    headers = {"Authorization" => "Bearer #{token}"}

    res = RestClient.get(url, headers)
    res.force_encoding("UTF-8").sub(/<string.*?">(.*)<\/string>/, '\1')
  end

  # ref. http://aoyagikouhei.blog8.fc2.com/blog-entry-163.html
  def judge_lang(text)
    if /(?:\p{Hiragana}|\p{Katakana}|[一-龠々])/ === text
      from = "ja"
      to   = "en"
    else
      from = "en"
      to   = "ja"
    end
    return {from: from, to: to}
  end
end

get "/" do
  "ok"
end

post "/" do
  unless params["team_domain"] == SLACK_TEAM
    halt 200, ""
  end

  word = params["text"]

  if word =~ /^@#{SLACK_USERNAME}: .*何と言っている？$/ || word =~ /^@#{SLACK_USERNAME}: translate$/i
    latest = open("|tail -n 1 < #{STORES_FILE}") { |f| f.gets.chomp }

    way = judge_lang(latest)
    translated = translate(latest, way)
    logger.info("translated word is #{translated}")

    says = if way[:to] == "ja"
             "「#{translated}」と言っている。"
           else
             "\"#{translated}\""
           end
    slack_client.notify(says)
  else
    File.open(STORES_FILE, 'a') do |f|
      f.puts word
    end
  end

  body ""
end

error do
  status 200
  body ""
end
