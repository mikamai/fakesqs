require "aws-sdk"
require "fakesqs/test_integration"

# Aws.config[:credentials] = {
#   :use_ssl           => false,
#   :sqs_endpoint      => "localhost",
#   :sqs_port          => 4568,
#   :access_key_id     => "fake access key",
#   :secret_access_key => "fake secret key",
# }
Aws.config.update(
  region: "us-east-1",
  credentials: Aws::Credentials.new("fake", "fake"),
)

db = ENV["SQS_DATABASE"] || ":memory:"
puts "\n\e[34mRunning specs with database \e[33m#{db}\e[0m"

$fakesqs = FakeSQS::TestIntegration.new(
  database: db,
  sqs_endpoint: "localhost",
  sqs_port: 4568,
)

RSpec.configure do |config|
  config.before(:each, :sqs) { $fakesqs.start }
  config.before(:each, :sqs) { $fakesqs.reset }
  config.after(:suite) { $fakesqs.stop }
end
