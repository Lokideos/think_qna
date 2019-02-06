# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notification/notify
  def notify
    NotificationMailer.notify
  end
end
