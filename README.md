![TravisCI status](https://travis-ci.org/gocardless/rspec-activejob.svg?branch=master)
# Installation

```gem install rspec-activejob ```

Or add it to the Gemfile into the :development and :test group

```ruby
# Gemfile
group :development, :test do
  ...
  gem 'rspec-activejob'
  ...
end
```

# RSpec ActiveJob matchers

```ruby
# config/environments/test.rb
config.active_job.queue_adapter = :test

# spec/spec_helper.rb
require 'rspec/active_job'

RSpec.configure do |config|
  config.include(RSpec::ActiveJob)

  # clean out the queue after each spec
  config.after(:each) do
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end
end

# spec/controllers/my_controller_spec.rb
RSpec.describe MyController do
  let(:user) { create(:user) }
  let(:params) { { user_id: user.id } }
  subject(:make_request) { described_class.make_request(params) }

  specify { expect { make_request }.to enqueue_a(RequestMaker).with(global_id(user)) }

  # or
  make_request
  expect(RequestMaker).to have_been_enqueued.with(global_id(user))
end
```

rspec-activejob expects the current queue adapter to expose an array of `enqueued_jobs`, like the included
test adapter. The test adapter included in ActiveJob 4.2.0 does not fully serialize its arguments, so you
will not need to use the GlobalID matcher unless you're using ActiveJob 4.2.1. See rails/rails#18266 for
the improved test adapter.

This gem defines four matchers:

* `enqueue_a`: for a block or proc, expects that to enqueue an job to the ActiveJob test adapter. Optionally
  takes the job class as its argument, and can be modified with a `.with(*args)` call to expect specific arguments.
  This will use the same argument list matcher as rspec-mocks' `receive(:message).with(*args)` matcher.
  If your job uses `set(wait_until: time)`, you can use `.to_run_at(time)` chain after `enqueue_a` call as well.
  In order to check for the right number of enqueued jobs use a `.once` or `.times(n)` modifiers.

* `have_been_enqueued`: expects to have enqueued an job in the ActiveJob test adapter. Optionally accepts all the
  same modifiers as `enqueue_a`.

* `global_id(model_or_class)`: an argument matcher, matching ActiveJob-serialized versions of model classes or
  specific models (or any other class which implements `to_global_id`). If you pass a model class, it will match
  the serialized version of any instance of that model; if you pass an instance, it will expect the serialized
  version of that specific instance.

* `deserialize_as(hash)`: an argument matcher, matching ActiveJob-serialized versions of hashes (with
  string/symbol keys, or with indifferent access).

With the `global_id` matcher it's important to note that it's specific to ActiveJob-serialized GlobalIDs.
ActiveJob serializes them as a hash like `{ '_aj_global_id' => 'gid://my-app/MyModel/ID123' }`, to avoid
clashes with plain strings which accidentally match the GlobalID syntax. This matcher will not work with
other usages of GlobalID.
