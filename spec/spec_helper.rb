$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tor_detector'

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.mock_with :rspec do |mocks|
    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true
  end
end
