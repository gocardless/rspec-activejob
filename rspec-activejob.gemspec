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
    * expect { method }.to enqueue_a(MyJob).with(global_id(some_model),
                                                 deserialize_as(other_argument))
  EOL
  s.homepage = 'http://github.com/gocardless/rspec-activejob'
  s.license = 'MIT'

  s.has_rdoc = false
  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.require_paths = %w(lib)

  s.add_runtime_dependency('activejob', '>= 4.2')
  s.add_runtime_dependency('rspec-mocks')

  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-its')
  s.add_development_dependency('activesupport')
  s.add_development_dependency('rubocop')
end
