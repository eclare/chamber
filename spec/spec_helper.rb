# refs. https://coveralls.io/docs/ruby
require 'simplecov'
require 'coveralls'
 
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/vendor/bundle'
end

# refs. http://qiita.com/rhzk/items/606c1d58afcfb06f14c4
ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'rspec'
require 'rack/test'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def app
  Sinatra::Application
end
