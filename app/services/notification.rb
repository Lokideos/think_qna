# frozen_string_literal: true

class Services::Notification
  def send_notification(question)
    NotificationMailer.notify(question).deliver_later
  end
end
