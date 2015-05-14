require 'spec_helper'

describe Assessments::ParticipantStatus do
  let(:subject) { Assessments::ParticipantStatus }

  before do
    @participant = Participant.new(
      invited_at: Time.now,
    )

    allow(@participant).to receive(:response)
      .and_return(true)

    allow(@participant).to receive_message_chain(:response, :submitted_at)
      .and_return(Time.now)
  end

  def status(participant = @participant)
    subject.new(participant).status
  end

  def date(participant = @participant)
    subject.new(participant).date
  end 

  it 'returns :pending' do
    @participant.invited_at = nil
    expect(status).to eq(:pending)
  end

  it 'returns :pending date' do
    @participant.invited_at = nil
    allow(@participant).to receive_message_chain(:assessment, :updated_at)
      .and_return(:expected)

    expect(date).to eq(:expected)
  end

  it 'returns :invited' do
    allow(@participant).to receive(:response)
      .and_return(nil)

    expect(status).to eq(:invited)
  end

  it 'returns :invited date' do
    allow(@participant).to receive(:response)
      .and_return(nil)

    allow(@participant).to receive(:invited_at)
      .and_return(:expected)

    expect(date).to eq(:expected)
  end

  it 'returns :in_progress' do
    allow(@participant).to receive_message_chain(:response, :submitted_at)
      .and_return(nil)

    expect(status).to eq(:in_progress)
  end

  it 'returns :in_progress date' do
    allow(@participant).to receive_message_chain(:response, :submitted_at)
      .and_return(nil)

    allow(@participant).to receive_message_chain(:response, :updated_at)
      .and_return(:expected)

    expect(date).to eq(:expected)
  end


  it 'returns :completed' do
    expect(status).to eq(:completed)
  end

  it 'returns the response submitted at date when completed' do
    allow(@participant).to receive_message_chain(:response, :submitted_at)
      .and_return(:expected)

    expect(date).to eq(:expected)
  end

  it 'returns :in_progress date' do
    allow(@participant).to receive_message_chain(:response, :submitted_at)
      .and_return(:expected)

    expect(date).to eq(:expected)
  end

  context '#to_s' do
    it 'converts the status into a string' do
      status = subject.new(@participant)
      expect(status.to_s).to eq("Completed")

      allow(status).to receive(:status).and_return :in_progress
      expect(status.to_s).to eq("In Progress")
    end
  end

end
