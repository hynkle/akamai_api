require 'spec_helper'

describe "Given I want to publish a request" do
  subject { AkamaiApi::ECCURequest }
  let(:fixture_content) { File.read 'spec/fixtures/eccu_request.xml' }

  context "when login credentials are invalid", vcr: { cassette_name: "akamai_api_eccu_publish/invalid_credentials" } do
    before do
      allow(AkamaiApi).to receive(:config) { { auth: ['foo', 'bar'] } }
      allow(AkamaiApi::ECCU).to receive(:client) { AkamaiApi::ECCU.send(:build_client) }
    end

    it "raises Unauthorized" do
      expect { subject.publish 'foo.com', fixture_content, file_name: './publish.xml' }.to raise_error AkamaiApi::Unauthorized
    end
  end

  context "when property name is not found", vcr: { cassette_name: "akamai_api_eccu_publish/invalid_domain" } do
    it "raises InvalidDomain" do
      expect { subject.publish 'foobarbaz.com', fixture_content, file_name: './publish.xml' }.to raise_error AkamaiApi::ECCU::InvalidDomain
    end
  end

  context "when data is correct", vcr: { cassette_name: "akamai_api_eccu_publish/successful" } do
    it "returns the request id" do
      expect(subject.publish 'foo.com', fixture_content, file_name: './publish.xml').to be_a Fixnum
    end
  end
end
