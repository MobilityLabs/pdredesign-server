require 'spec_helper'

describe V1::OrganizationsController do
  describe '#create' do
    it 'creates an organization'
    it 'returns errors for an invalid org'
  end

  describe '#update' do
    it 'updates an organization' 
    it 'returns errors for an invalid update' 
  end

  describe '#search' do
    it 'returns a searched org'
  end

  describe '#show' do
    it 'finds the correct organization'
  end
end
