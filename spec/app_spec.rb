require "spec_helper"

describe "GET /" do
  before { get "/" }
  subject(:response) { last_response }
  it "returns 200 ok" do
    expect(response.status.to_i).to eq(200)
  end
end
