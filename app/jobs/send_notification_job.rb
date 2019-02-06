# frozen_string_literal: true

class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(question)
    question.subscribed_users.each do |user|
      NotificationMailer.notify(question, user).deliver_later
    end
  end
end
