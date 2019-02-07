# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendNotificationJob, type: :job do
  let(:users) { create_list(:user, 3) }
  let(:question) { create(:question, user: users.first) }

  before do
    users.each do |user|
      user.subscribe(question) unless user.subscribed?(question)
    end
  end

  it 'sends notifications to subscribed users' do
    users.each do |user|
      expect(NotificationMailer).to receive(:notify).with(question, user).and_call_original
    end

    SendNotificationJob.perform_now(question)
  end
end
