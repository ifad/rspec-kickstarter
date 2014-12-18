require 'simplecov'


if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

Spec::Runner.configure do |config|
end

