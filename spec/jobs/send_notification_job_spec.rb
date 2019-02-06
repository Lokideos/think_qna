# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendNotificationJob, type: :job do
  let(:question) { create(:question) }

  it 'sends notification' do
    expect(NotificationMailer).to receive(:notify).with(question).and_call_original
    SendNotificationJob.perform_now(question)
  end
end
