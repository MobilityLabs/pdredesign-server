shared_examples_for 'a tool which adds initial messages' do |tool_str|
  context 'when saving once' do
    context 'when the tool is not assigned' do
      let(:tool) {
        build(tool_str.to_sym, :with_participants, message: '<p>Initial message!</p>')
      }

      before(:each) do
        tool.save!
      end

      it 'does not add a message to the messages table' do
        expect(Message.where(tool: tool)).to be_empty
      end
    end

    context 'when the tool is assigned' do
      let(:tool) {
        build(tool_str.to_sym, :with_participants, message: '<p>Default message!  One with a bit of <b>bold</b> as well.</p>', assigned_at: Time.now)
      }

      before(:each) do
        tool.save!
      end

      it 'adds the message to the messages table' do
        expect(Message.where(tool: tool)).not_to be_empty
      end

      it 'does not include any HTML tags' do
        expect(Message.where(tool: tool).first.content).to eq 'Default message!  One with a bit of bold as well.'
      end

      it 'sets the category to "welcome"' do
        expect(Message.where(tool: tool).first.category).to eq 'welcome'
      end
    end
  end

  context 'when saving multiple times' do
    let(:tool) {
      build(tool_str.to_sym, :with_participants, message: '<p>Default message!</p>', assigned_at: Time.now)
    }

    before(:each) do
      tool.save!
      tool.save!
    end

    it 'does not add multiple messages' do
      expect(Message.where(tool: tool).size).to eq 1
    end
  end
end