require 'spec_helper'

shared_examples 'successful_invitation' do
  it 'responds successfully' do
    expect(response).to have_http_status(:success)
  end

  it 'creates an invitation' do
    expect(created_invitation).not_to be_nil
  end

  it 'sets inventory in invitation' do
    expect(created_invitation.inventory).to eq inventory
  end

  it 'sets invitation first_name' do
    expect(created_invitation.first_name).to eq 'john'
  end

  it 'sets invitation last_name' do
    expect(created_invitation.last_name).to eq 'doe'
  end

  it 'sets invitation team_role' do
    expect(created_invitation.team_role).to eq 'Finance'
  end

  it 'sets invitation role' do
    expect(created_invitation.role).to eq 'facilitator'
  end
end

