require 'spec_helper'

describe ReqSample::Countries do
  let(:countries) { subject.new }

  it 'samples addresses' do
    expect(subject.sample_address).to be_an(IPAddr)
  end

  it 'samples response codes' do
    expect(subject.sample_code).to match(/[0-9]{3}/)
  end

  it 'samples countries' do
    expect(subject.sample_country).to match(/[a-z]{2}/)
  end
end
