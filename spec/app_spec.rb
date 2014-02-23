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

shared_examples "the size of word file is 0" do
  specify { expect(words_file.size).to eq(0) }
end

describe "GET /" do
  before { get "/" }
  subject(:response) { last_response }
  it_behaves_like "200 ok"
end

describe "POST /" do
  let(:params) { {team_domain: team_domain, text: text} }
  let(:words_file) { Tempfile.open("words") }
  let(:text) { "something" }
  let(:team_domain) { "hogehoge" }

  before do
    stub_const("SLACK_TEAM", "hogehoge")
    stub_const("SLACK_WORDS_FILE", words_file.path)
  end
  after { words_file.close! }

  subject(:response) { last_response }

  context "invalid team domain" do
    let(:team_domain) { "fugafuga" }

    before { post "/", params }

    it_behaves_like "200 ok"
    it_behaves_like "empty body"
    it_behaves_like "the size of word file is 0"
  end

  context "no 'text' key in params" do
    before { post "/", {team_domain: team_domain} }

    it_behaves_like "200 ok"
    it_behaves_like "empty body"
    it_behaves_like "the size of word file is 0"
  end

  context "not trigger word" do
    before { post "/", params }

    it_behaves_like "200 ok"
    it_behaves_like "empty body"
    specify "the word is stored" do
      expect(File.read(words_file.path)).to eq("#{text}\n")
    end
  end
end
