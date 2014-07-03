require 'spec_helper'

describe Twitter::UpdateAvatar do
  let(:subject) { Twitter::UpdateAvatar }

  before do
    @user = Application::create_sample_user
    @user.update(twitter: 'some_user')
  end

  it 'takes a user as the init var' do
    expect(subject.new(@user).user).to eq(@user)
  end

  context 'with instance' do
    before do
      @instance = subject.new(@user)
    end

    it 'has the right configuration' do
      Rails.application.config.twitter_config = :expected
      expect(@instance.send(:client_config)).to eq(:expected)
    end

    it 'create the client with the right configs' do
      Rails.application.config.twitter_config = :expected
      expect(Twitter::REST::Client).to receive(:new).with(:expected)
      @instance.send(:client)
    end

    it 'does not access twitter when user is nil' do
      @user.update(avatar: 'expected', twitter: '')
      expect(@instance).not_to receive(:user_avatar)

      @instance.execute
      expect(@user.avatar).to eq('expected')
    end

    it 'does not alter a user when avatar is not found' do
      @user.update(avatar: 'some_avatar')

      expect(@instance).to receive(:user_avatar) do
        raise Twitter::Error::NotFound
      end

      @instance.execute
      expect(@user.avatar).to eq('some_avatar')
    end

    it 'updates a users avatar from twitter' do
      url = "http://www.google.com"
      expect(@instance).to receive(:user_avatar).and_return(url)
      
      @instance.execute
      expect(@user.avatar).to eq(url)
    end

    describe '#user_avatar' do
      it 'gets the users avatar url' do
        url               = "http://www.friendface.com"
        fake_twitter_user = double("fake_twitter_user")
        
        allow(fake_twitter_user).to receive(:profile_image_uri)
          .and_return(url)

        allow(@instance).to receive_message_chain(:client, :user)
          .and_return(fake_twitter_user)

        @instance.execute

        expect(@user.avatar).to eq(url)
      end
    end

  end

end
