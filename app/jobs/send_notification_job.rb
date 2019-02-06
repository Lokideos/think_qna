# frozen_string_literal: true

class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(question)
    NotificationMailer.notify(question).deliver_later
  end
end
