# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.notify.subject
  #
  def notify(question, user)
    @greeting = 'Hi'
    @user = user
    @question = question

    mail to: @user.email
  end
end
