# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Services::Notification do
  let(:question) { create(:question) }

  it 'sends notification' do
    expect(NotificationMailer).to receive(:notify).with(question).and_call_original
    subject.send_notification(question)
  end
end
