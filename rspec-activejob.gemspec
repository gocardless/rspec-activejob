require File.expand_path('../lib/rspec/active_job/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'rspec-activejob'
  s.version = RSpec::ActiveJob::VERSION
  s.date = Date.today.strftime('%Y-%m-%d')
  s.authors = ['Isaac Seymour']
  s.email = ['isaac@isaacseymour.co.uk']
  s.summary = 'RSpec matchers to test ActiveJob'
  s.description = <<-EOL
    RSpec matchers for ActiveJob:
    * expect { method }.to enqueue_a(MyJob).with('some', 'arguments')
  EOL
  s.homepage = 'http://github.com/gocardless/rspec-activejob'
  s.license = 'MIT'

  s.has_rdoc = false
  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = %w(lib)
end
