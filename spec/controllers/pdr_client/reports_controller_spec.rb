require 'spec_helper'

describe PdrClient::ReportsController do
  describe 'GET #consensus_report' do
    context 'when retrieving a PDF' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let!(:preexisting_response) {
        create(:response, responder: assessment)
      }

      before(:each) do
        allow(controller).to receive(:render_to_string).and_return('{}')
        post :consensus_report, params: { assessment_id: assessment.id }, format: :pdf
      end

      it {
        expect(response.body).to match('PDF')
      }

      it {
        expect(response.headers['Content-Disposition']).to eq('attachment; filename="report.pdf"')
      }

      it {
        expect(response.headers['Content-Type']).to eq('application/pdf')
      }

      it {
        is_expected.to respond_with :success
      }
    end

    context 'when retrieving a CSV' do
      let(:assessment) {
        create(:assessment, :with_participants)
      }

      let!(:preexisting_response) {
        create(:response, responder: assessment)
      }

      before(:each) do
        allow(controller).to receive(:render_to_string).and_return('{}')
        post :consensus_report, params: { assessment_id: assessment.id }, format: :csv
      end

      it {
        expect(response.headers['Content-Disposition']).to eq('attachment; filename=report.csv')
      }

      it {
        expect(response.headers['Content-Type']).to eq('text/csv')
      }

      it {
        is_expected.to respond_with :success
      }
    end
  end
end
