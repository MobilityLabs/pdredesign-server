require 'spec_helper'

describe ExtractIds do
  include ExtractIds

  it 'can extract ids' do
    allow(self).to receive(:params).and_return(example: '1,2,3')

    expect(extract_ids_from_params(:example)).to eq(['1','2','3'])
  end

  it 'can extract single id' do
    allow(self).to receive(:params).and_return(example: '1')

    expect(extract_ids_from_params(:example)).to eq(['1'])
  end

  it 'doesnt die with Fixnum' do
    allow(self).to receive(:params).and_return(example: 1)

    expect(extract_ids_from_params(:example)).to eq([1])
  end
end
