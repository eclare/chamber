require "spec_helper"
require "tempfile"

shared_examples "200 ok" do
  it "returns 200 ok" do
    expect(response.status.to_i).to eq(200)
  end
end

shared_examples "empty body" do
  it "returns nothing in HTTP body" do
    expect(response.body).to be_empty
  end
end

describe "GET /" do
  before { get "/" }
  subject(:response) { last_response }
  it_behaves_like "200 ok"
end

describe "POST /" do
  let(:params) { {team_domain: team_domain, text: text} }
  let(:words_file) { Tempfile.open("words") }
  before { ENV["SLACK_WORDS_FILE"] = words_file.path }
  after { words_file.close! }

  context "invalid team domain" do
    let(:team_domain) { "hogehoge" }
    let(:text) { "something" }

    before do
      ENV["SLACK_TEAM"] = "fugafuga"
      post "/", params
    end

    subject(:response) { last_response }

    it_behaves_like "200 ok"
    it_behaves_like "empty body"
    specify { expect(words_file.size).to eq(0) }
  end
end
