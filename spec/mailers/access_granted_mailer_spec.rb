require 'spec_helper'

describe AccessGrantedMailer do
  before { create_magic_assessments }
  let(:subject){ AccessGrantedMailer }
  let(:assessment){ @assessment_with_participants }
  let(:user){ Application.create_user } 

  it "#notify" do
    mail = subject.notify(assessment, user)
    expect(mail.to).to include(user.email)
  end
end