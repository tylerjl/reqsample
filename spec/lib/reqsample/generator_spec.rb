require 'spec_helper'

describe ReqSample::Generator do
  let(:countries) { subject.new }

  it 'samples addresses' do
    expect(subject.sample_address).to be_an(IPAddr)
  end

  it 'samples response codes' do
    expect(subject.codes.weighted_sample).to match(/[0-9]{3}/)
  end

  it 'samples countries' do
    expect(subject.connectivity.weighted_sample).to match(/[a-z]{2}/)
  end

  it 'samples time' do
    expect(subject.sample_time(Time.now, 12)).to be_a(Time)
  end
end
