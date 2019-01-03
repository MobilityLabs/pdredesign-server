# == Schema Information
#
# Table name: assessments
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  due_date        :datetime
#  meeting_date    :datetime
#  user_id         :integer
#  rubric_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  district_id     :integer
#  message         :text
#  assigned_at     :datetime
#  report_takeaway :text
#  share_token     :string
#

require 'spec_helper'
require 'support/message_migration_concern_shared_example'

describe Assessment do
  it_behaves_like 'a tool which adds initial messages', described_class.to_s.downcase

  it {
    is_expected.to validate_presence_of :name
  }

  it {
    is_expected.to validate_presence_of :rubric_id
  }

  it {
    is_expected.to validate_presence_of :district_id
  }

  it {
    is_expected.to validate_presence_of :due_date
  }

  context 'when the due date is in the past' do
    subject {
      build(:assessment, :with_owner)
    }

    before(:each) do
      subject.due_date = 1.minute.ago
      subject.save
    end

    it 'has only one error' do
      expect(subject.errors.size).to eq 1
    end

    it 'gives back the correct error message' do
      expect(subject.errors[:due_date][0]).to eq 'cannot be in the past'
    end
  end

  context 'when meeting date is set to be in the past' do
    context 'when first saving the assessment' do
      context 'when the assessment is created before noon' do
        let(:assessment) {
          build(:assessment)
        }

        let(:current_time) {
          Time.current.at_beginning_of_day + 11.hours
        }

        let(:current_date) {
          current_time.strftime('%D')
        }

        before(:each) do
          allow(Time).to receive(:current).and_return(current_time)
          assessment.meeting_date = 5.weeks.ago
          assessment.save
        end

        it {
          expect(assessment.valid?).to be false
        }

        it {
          expect(assessment.errors[:meeting_date]).to include "must be set no earlier than #{(Time.current + 1.day).strftime('%D')}"
        }
      end

      context 'when the assessment is created at noon' do
        let(:assessment) {
          build(:assessment)
        }

        let(:current_time) {
          Time.current.at_beginning_of_day + 12.hours
        }

        let(:current_date) {
          current_time.strftime('%D')
        }

        before(:each) do
          allow(Time).to receive(:current).and_return(current_time)
          assessment.meeting_date = 5.weeks.ago
          assessment.save
        end

        it {
          expect(assessment.valid?).to be false
        }

        it {
          expect(assessment.errors[:meeting_date]).to include "must be set no earlier than #{(Time.current + 2.days).strftime('%D')}"
        }
      end

      context 'when the assessment is created after noon' do
        let(:assessment) {
          build(:assessment)
        }

        let(:current_time) {
          Time.current.at_beginning_of_day + 12.hours
        }

        let(:current_date) {
          current_time.strftime('%D')
        }

        before(:each) do
          allow(Time).to receive(:current).and_return(current_time)
          assessment.meeting_date = 5.weeks.ago
          assessment.save
        end

        it {
          expect(assessment.valid?).to be false
        }

        it {
          expect(assessment.errors[:meeting_date]).to include "must be set no earlier than #{(Time.current + 2.days).strftime('%D')}"
        }
      end

    end
  end

  context 'when assigned_at is present' do
    context 'when message is invalid' do
      let(:participants) {
        create_list(:participant, 2)
      }

      let(:assessment) {
        build(:assessment, participants: participants, assigned_at: Time.now, due_date: 5.days.from_now)
      }

      before(:each) do
        assessment.save
      end

      it {
        expect(assessment.valid?).to be false
      }

      it {
        expect(assessment.errors[:message]).to include 'can\'t be blank'
      }
    end

    context 'when no participants are attached' do
      let(:assessment) {
        build(:assessment, assigned_at: Time.now, due_date: 5.days.from_now, message: 'msg')
      }

      before(:each) do
        assessment.save
      end

      it {
        expect(assessment.valid?).to be false
      }

      it {
        expect(assessment.errors[:participants]).to include 'must be assigned to this assessment'
      }
    end

    context 'when all fields are specified' do
      let(:participants) {
        create_list(:participant, 2)
      }

      let(:assessment) {
        build(:assessment, participants: participants, assigned_at: Time.now, due_date: 5.days.from_now, message: 'msg')
      }

      before(:each) do
        assessment.save
      end

      it {
        expect(assessment.valid?).to be true
      }
    end
  end

  describe '#pending_requests?' do
    context 'on an assessment without any outstanding requests' do
      let(:access_request) {
        create(:access_request)
      }

      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let(:user) {
        access_request.user
      }

      it {
        expect(assessment.pending_requests?(user)).to be false
      }
    end

    context 'on an assessment with outstanding requests' do
      let(:access_request) {
        create(:access_request)
      }

      let(:assessment) {
        access_request.tool
      }

      let(:user) {
        access_request.user
      }

      it {
        expect(assessment.pending_requests?(user)).to be true
      }
    end
  end

  describe '#completed?' do
    context 'when percent_completed is equal to 100' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      it {
        allow(assessment).to receive(:percent_completed).and_return 100
        expect(assessment.completed?).to be true
      }
    end

    context 'when percent_completed is less than 100' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      it {
        allow(assessment).to receive(:percent_completed).and_return 99
        expect(assessment.completed?).to be false
      }
    end

    context 'when percent_completed is greater than 100' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      it {
        allow(assessment).to receive(:percent_completed).and_return 101
        expect(assessment.completed?).to be false
      }
    end
  end

  describe '#status' do
    context 'when assigned_at is nil' do
      let(:assessment) {
        create(:assessment, :with_participants, assigned_at: nil)
      }

      it {
        expect(assessment.status).to eq :draft
      }
    end

    context 'when response is present' do
      let(:assessment) {
        create(:assessment, :with_participants, :with_response)
      }

      it {
        expect(assessment.status).to eq :consensus
      }
    end

    context 'when assigned_at is not nil and response is absent' do
      let(:assessment) {
        create(:assessment, :with_participants, assigned_at: Time.now)
      }

      it {
        expect(assessment.status).to eq :assessment
      }
    end
  end

  describe '#share_token' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    let(:original_share_token) {
      assessment.share_token
    }

    it {
      expect(assessment.share_token).not_to be_empty
    }

    describe 'when saved again' do
      before(:each) do
        assessment.save!
      end

      it {
        expect(assessment.share_token).to eq original_share_token
      }
    end
  end

  describe '#answered_scores' do
    let(:response) {
      create(:response, :as_assessment_response, :submitted)
    }

    let(:first_user_response) {
      create(:response, :as_participant_responder, responder: assessment.participants.first)
    }

    let(:second_user_response) {
      create(:response, :as_participant_responder, responder: assessment.participants.last)
    }

    let(:assessment) {
      response.responder
    }

    context 'when pulling back all existing scores' do

      let!(:rubric) {
        create(:rubric, :with_questions_and_scores,
               question_count: 3,
               scores: [{
                            response: first_user_response,
                            value: 1,
                            evidence: 'expected'
                        },
                        {
                            response: second_user_response,
                            value: 1,
                            evidence: 'expected'
                        },
                        {
                            response: second_user_response,
                            value: 1,
                            evidence: 'expected'
                        }
               ],
               answers: [{
                             value: 1,
                             content: 'some content'
                         },
                         {
                             value: 2,
                             content: 'some content'
                         },
                         {
                             value: 3,
                             content: 'some content'
                         },
                         {
                             value: 4,
                             content: 'some content'
                         }]
        )
      }

      it {
        expect(assessment.answered_scores.count).to eq(3)
      }
    end

    context 'when a score does not contain evidence' do
      let!(:rubric) {
        create(:rubric, :with_questions_and_scores,
               question_count: 3,
               scores: [{
                            response: first_user_response,
                            value: 1,
                            evidence: ''
                        },
                        {
                            response: second_user_response,
                            value: 1,
                            evidence: 'expected'
                        },
                        {
                            response: second_user_response,
                            value: 1,
                            evidence: 'expected'
                        }
               ],
               answers: [{
                             value: 1,
                             content: 'some content'
                         },
                         {
                             value: 2,
                             content: 'some content'
                         },
                         {
                             value: 3,
                             content: 'some content'
                         },
                         {
                             value: 4,
                             content: 'some content'
                         }]
        )
      }

      it {
        expect(assessment.answered_scores.count).to eq(2)
      }
    end

    context 'when the score is skipped' do
      let!(:rubric) {
        create(:rubric, :with_questions_and_scores,
               question_count: 3,
               scores: [{
                            response: first_user_response,
                            value: nil,
                            evidence: 'needs evidence'
                        },
                        {
                            response: second_user_response,
                            value: 1,
                            evidence: 'expected'
                        },
                        {
                            response: second_user_response,
                            value: 1,
                            evidence: 'expected'
                        }
               ],
               answers: [{
                             value: 1,
                             content: 'some content'
                         },
                         {
                             value: 2,
                             content: 'some content'
                         },
                         {
                             value: 3,
                             content: 'some content'
                         },
                         {
                             value: 4,
                             content: 'some content'
                         }]
        )
      }

      it {
        expect(assessment.answered_scores.count).to eq(3)
      }
    end

    describe '#scores_for_team_role' do
      let(:response) {
        create(:response, :as_assessment_response, :submitted)
      }

      let(:assessment) {
        response.responder
      }

      context 'when there are no roles for any participants' do
        let(:first_user_response) {
          create(:response, :as_participant_responder, responder: assessment.participants.first)
        }

        let!(:rubric) {
          create(:rubric, :with_questions_and_scores,
                 scores: [{
                              response: first_user_response,
                              value: 1,
                              evidence: 'needs evidence'
                          }
                 ],
                 answers: [{
                               value: 1,
                               content: 'some content'
                           }]
          )
        }

        let(:team_role) {
          :worker
        }

        it {
          expect(assessment.scores_for_team_role(:worker).count).to eq 0
        }
      end

      context 'when there is a role for a participant' do
        context 'when the response is not skipped' do
          let(:participant_with_role) {
            p = assessment.participants.first
            p.user.update(team_role: :worker)
            p
          }

          let(:first_user_response) {
            create(:response, :as_participant_responder, responder: participant_with_role)
          }

          let!(:rubric) {
            create(:rubric, :with_questions_and_scores,
                   scores: [{
                                response: first_user_response,
                                value: 1,
                                evidence: 'needs evidence'
                            }

                   ],
                   answers: [{
                                 value: 1,
                                 content: 'some content'
                             }]
            )
          }

          let(:team_role) {
            :worker
          }

          it {
            expect(assessment.scores_for_team_role(:worker).count).to eq 1
          }
        end

        context 'when the response does not contain evidence' do
          let(:participant_with_role) {
            p = assessment.participants.first
            p.user.update(team_role: :worker)
            p
          }

          let(:first_user_response) {
            create(:response, :as_participant_responder, responder: participant_with_role)
          }

          let!(:rubric) {
            create(:rubric, :with_questions_and_scores,
                   scores: [{
                                response: first_user_response,
                                value: 1,
                                evidence: nil
                            }

                   ],
                   answers: [{
                                 value: 1,
                                 content: 'some content'
                             }]
            )
          }

          let(:team_role) {
            :worker
          }

          it {
            expect(assessment.scores_for_team_role(:worker).count).to eq 0
          }
        end
      end
    end

    describe '#team_roles_for_participants' do

      let(:assessment) {
        create(:assessment, :with_participants)
      }

      context 'when participants do not have roles' do
        it {
          expect(assessment.team_roles_for_participants).to be_empty
        }
      end

      context 'when participants have roles' do
        context 'when participants have the same role' do
          before(:each) do
            assessment.participants.first.user.update(team_role: :worker)
            assessment.participants.last.user.update(team_role: :worker)
          end

          it {
            expect(assessment.team_roles_for_participants).to eq ['worker']
          }
        end

        context 'when participants have different roles' do
          before(:each) do
            assessment.participants.first.user.update(team_role: :worker)
            assessment.participants.last.user.update(team_role: :non_worker)
          end

          it {
            expect(assessment.team_roles_for_participants.sort).to eq %w(worker non_worker).sort
          }
        end
      end
    end

    describe '#scores' do
      let(:response) {
        create(:response, :as_assessment_response, :submitted)
      }

      let(:assessment) {
        response.responder
      }

      let(:first_user_response) {
        create(:response, :as_participant_responder, responder: assessment.participants.first)
      }

      let!(:rubric) {
        create(:rubric, :with_questions_and_scores,
               scores: [{
                            response: first_user_response,
                            value: 1,
                            evidence: nil
                        }

               ],
               answers: [{
                             value: 1,
                             content: 'some content'
                         }]
        )
      }

      it {
        expect(assessment.scores(Question.first).count).to eq 1
      }
    end
  end

  describe '#score_count' do
    let(:response) {
      create(:response, :as_assessment_response, :submitted)
    }

    let(:assessment) {
      response.responder
    }

    let(:first_user_response) {
      create(:response, :as_participant_responder, :submitted, responder: assessment.participants.first)
    }

    context 'when scores for the given value do not exist' do
      let!(:rubric) {
        create(:rubric, :with_questions_and_scores,
               scores: [{
                            response: first_user_response,
                            value: 1,
                            evidence: 'evidenced'
                        }

               ],
               answers: [{
                             value: 1,
                             content: 'some content'
                         }]
        )
      }

      it {
        expect(assessment.score_count(Question.first, 10)).to eq 0
      }
    end

    context 'when scores for the given value exist' do

      let!(:rubric) {
        create(:rubric, :with_questions_and_scores,
               scores: [{
                            response: first_user_response,
                            value: 1,
                            evidence: 'It counts...'
                        }

               ],
               answers: [{
                             value: 1,
                             content: 'some content'
                         }]
        )
      }

      it {
        expect(assessment.score_count(Question.first, 1)).to eq 1
      }
    end
  end

  describe 'Assessment#assessments_for_user' do

    let(:district) {
      create(:district)
    }

    context 'when user has multiple assessments' do
      context 'when user does not have a role' do
        let(:user) {
          create(:user, districts: [district])
        }

        let!(:assessments) {
          create_list(:assessment, 3, :with_participants) do |assessment|
            assessment.participants << create(:participant, user: user)
            assessment.district = district
            assessment.save!
          end
        }

        it {
          expect(Assessment.assessments_for_user(user).size).to eq 3
        }
      end

      context 'when user has a role' do
        let(:user) {
          create(:user, districts: [district], role: :member)
        }

        let!(:assessments) {
          create_list(:assessment, 3, :with_participants) do |assessment|
            assessment.participants << create(:participant, user: user)
            assessment.district = district
            assessment.save!
          end
        }

        it {
          expect(Assessment.assessments_for_user(user).size).to eq 3
        }
      end
    end

    context 'when user is a network partner' do
      let(:user) {
        create(:user, districts: [district, other_district], role: :network_partner)
      }

      let(:other_district) {
        create(:district)
      }

      let!(:district_assessments) {
        create_list(:assessment, 3, :with_participants) do |assessment|
          assessment.participants << create(:participant, user: user)
          assessment.district = district
          assessment.save!
        end
      }

      let!(:other_district_assessments) {
        create_list(:assessment, 3, :with_participants) do |assessment|
          assessment.participants << create(:participant, user: user)
          assessment.district = other_district
          assessment.save!
        end
      }

      it {
        expect(Assessment.assessments_for_user(user).size).to eq 6
      }
    end
  end

  describe '#participant?' do
    context 'when the user is a participant' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let(:user) {
        assessment.participants.sample.user
      }

      it {
        expect(assessment.participant?(user)).to be true
      }
    end

    context 'when the user is not a participant' do
      let(:assessment) {
        create(:assessment)
      }

      let(:user) {
        create(:user, :with_district)
      }

      it {
        expect(assessment.participant?(user)).to be false
      }
    end
  end

  describe '#has_access?' do
    context 'when the user is a participant' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let(:user) {
        assessment.participants.sample.user
      }

      it {
        expect(assessment.has_access?(user)).to be true
      }
    end

    context 'when the user is a facilitator' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let(:user) {
        assessment.facilitators.sample
      }

      it {
        expect(assessment.has_access?(user)).to be true
      }
    end

    context 'when the user is the owner' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let(:user) {
        assessment.user
      }

      it {
        expect(assessment.has_access?(user)).to be true
      }
    end

    context 'when the user is not a part of the assessment' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let(:user) {
        create(:user)
      }

      it {
        expect(assessment.has_access?(user)).to be false
      }
    end
  end

  describe '#consensus' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when a consensus is present' do
      let!(:response) {
        r = create(:response, :as_assessment_response, responder: assessment)
        r.responder = assessment
        r.save!
        r
      }

      it {
        expect(assessment.consensus.id).to_not be_nil
      }
    end

    context 'when a consensus is not present' do
      it {
        expect(assessment.consensus).to be_nil
      }
    end
  end

  describe '#responses' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when user is a facilitator' do
      let(:user) {
        assessment.facilitators.sample
      }


      let!(:response) {
        create(:response, :as_participant_response, responder: user)
      }

      it {
        expect(assessment.responses(user)).to be_empty
      }
    end

    context 'when user is the owner' do
      let(:user) {
        assessment.user
      }

      let!(:response) {
        create(:response, :as_participant_response, responder: user)
      }

      it {
        expect(assessment.responses(user)).to be_empty
      }
    end

    context 'when user is a participant' do
      context 'when there are no responses' do
        let(:user) {
          assessment.participants.sample.user
        }

        it {
          expect(assessment.responses(user)).to be_empty
        }
      end

      context 'when there are responses' do
        let(:user) {
          participant.user
        }

        let(:participant) {
          assessment.participants.sample
        }

        let!(:response) {
          create(:response, :as_participant_response, responder: participant)
        }

        it {
          expect(assessment.responses(user)).to eq [response]
        }
      end
    end
  end

  describe '#participant_responses' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when response has not been submitted' do
      let(:participant) {
        assessment.participants.sample
      }

      let!(:response) {
        create(:response, :as_participant_response, responder: participant)
      }

      it {
        expect(assessment.participant_responses).to be_empty
      }
    end

    context 'when response has been submitted' do
      let(:participant) {
        assessment.participants.sample
      }

      let!(:response) {
        create(:response, :as_participant_response, :submitted, responder: participant)
      }

      it {
        expect(assessment.participant_responses.include?(response)).to be true
      }
    end
  end

  describe '#participants_not_responded' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when response has not been submitted' do
      let(:participant) {
        assessment.participants.sample
      }

      let!(:response) {
        create(:response, :as_participant_response, responder: participant)
      }

      it {
        expect(assessment.participants_not_responded.include?(participant)).to be true
      }
    end

    context 'when response has been submitted' do
      # Code smell - please see #participants_not_responded for an explanation as to why
      # all participants are required to submit a response in this context
      let!(:responses) {
        assessment.participants.each {|assessment_participant|
          create(:response, :as_participant_response, :submitted, responder: assessment_participant)
        }
      }

      it {
        expect(assessment.participants_not_responded).to be_empty
      }
    end
  end

  describe '#participants_viewed_report' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when declared unseen' do
      let!(:participant) {
        assessment.participants.sample
      }

      it {
        expect(assessment.participants_viewed_report).to be_empty
      }
    end

    context 'when declared seen' do
      let!(:participant) {
        p = assessment.participants.sample
        p.report_viewed_at = Time.now
        p.save!
        p
      }

      it {
        expect(assessment.participants_viewed_report.include?(participant)).to be true
      }
    end
  end

  describe '#response_submitted?' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when a response is submitted' do
      let!(:response) {
        r = create(:response, :as_assessment_response, :submitted)
        r.responder = assessment
        r.save!
        r
      }

      it {
        expect(assessment.response_submitted?).to be true
      }
    end

    context 'when a response is not submitted' do
      let!(:response) {
        r = create(:response, :as_assessment_response, responder: assessment)
        r.responder = assessment
        r.save!
        r
      }

      it {
        expect(assessment.response_submitted?).to be false
      }
    end
  end

  describe '#percent_completed' do
    let(:assessment) {
      create(:assessment, :with_participants)
    }

    context 'when no responses have been submitted' do
      let!(:responses) {
        assessment.participants.each {|assessment_participant|
          create(:response, :as_participant_response, responder: assessment_participant)
        }
      }

      it {
        expect(assessment.percent_completed).to be_within(0.01).of 0.0
      }
    end

    context 'when half of the responses have been submitted' do
      let!(:responses) {
        submitted = false
        assessment.participants.each {|assessment_participant|
          if submitted
            create(:response, :as_participant_response, responder: assessment_participant)
          else
            create(:response, :as_participant_response, :submitted, responder: assessment_participant)
            submitted = true
          end
        }
      }

      it {
        expect(assessment.percent_completed).to be_within(0.01).of 50.0
      }
    end

    context 'when all of the responses have been submitted' do
      let!(:responses) {
        assessment.participants.each {|assessment_participant|
          create(:response, :as_participant_response, :submitted, responder: assessment_participant)
        }
      }

      it {
        expect(assessment.percent_completed).to be_within(0.01).of 100.0
      }
    end
  end

  describe "#flush_cached_version" do

    it {
      is_expected.to respond_to(:flush_cached_version)
    }

    context 'when invoking the method' do
      let!(:assessment) {
        create(:assessment)
      }

      let!(:previous_updated_at_value) {
        assessment.updated_at
      }

      before(:each) do
        assessment.flush_cached_version
        assessment.reload
      end

      it 'changes the updated_at for the assessment' do
        expect(assessment.updated_at).to_not eq previous_updated_at_value
      end
    end
  end

  describe '#all_users' do
    let(:assessment) {
      create(:assessment, :with_participants, :with_network_partners)
    }

    let(:participants) {
      assessment.participants.map(&:user)
    }

    let(:facilitators) {
      assessment.facilitators
    }

    let(:network_partners) {
      assessment.network_partners
    }

    let(:owner) {
      [assessment.user]
    }

    it {
      expect(assessment.all_users & participants).to eq participants
    }

    it {
      expect(assessment.all_users & facilitators).to eq facilitators
    }

    it {
      expect(assessment.all_users & network_partners).to eq network_partners
    }

    it {
      expect(assessment.all_users & owner).to_not eq owner
    }

    it {
      expect(assessment.all_users.uniq).to eq assessment.all_users
    }
  end

  context '#facilitator?' do
    context 'when user is a facilitator' do
      let(:assessment) {
        create(:assessment, :with_participants)
       }

      let(:user) {
        assessment.facilitators.sample
      }

      it {
        expect(assessment.facilitator?(user)).to be true
      }
    end

    context 'when user is not a facilitator' do
      let(:assessment) {
        create(:assessment, :with_participants)
       }

      let(:user) {
        create(:user, :with_district)
      }

      it {
        expect(assessment.facilitator?(user)).to be false
      }
    end
  end

  context '#network_partner?' do
    context 'when user is a network partner' do
      let(:assessment) {
        a = create(:assessment, :with_participants)
        a.network_partners << user
        a
      }

      let(:user) {
        create(:user, :with_district)
      }

      it {
        expect(assessment.network_partner?(user)).to be true
      }
    end

    context 'when user is not a network partner' do
      let(:assessment) {
        a = create(:assessment, :with_participants)
        a.network_partners << create(:user, :with_district)
        a
      }

      let(:user) {
        create(:user)
      }

      it {
        expect(assessment.network_partner?(user)).to be false
      }
    end
  end
end
