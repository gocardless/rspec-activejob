# RSpec ActiveJob matchers

```ruby
RSpec.configure do |config|
  config.include(RSpec::ActiveJob)
end

RSpec.describe MyController do
  let(:user) { create(:user) }
  let(:params) { { user_id: user.id } }
  subject(:make_request) { described_class.make_request(params) }

  specify { expect { make_request }.to enqueue_a(RequestMaker).with(user) }
end
```