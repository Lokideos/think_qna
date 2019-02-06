# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendNotificationJob, type: :job do
  let(:service) { double('Services::Notification') }
  let(:question) { double('Question.new') }

  before do
    allow(Services::Notification).to receive(:new).and_return(service)
  end

  it 'calls Service::Notification#notify' do
    expect(service).to receive(:send_notification).with(question)
    SendNotificationJob.perform_now(question)
  end
end
