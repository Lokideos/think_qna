# frozen_string_literal: true

class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(question)
    Services::Notification.new.send_notification(question)
  end
end
