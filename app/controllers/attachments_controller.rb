# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :authenticate_user!

  # rubocop:disable Metrics/LineLength
  def destroy
    @attachment_id = params[:id]
    attachment = ActiveStorage::Attachment.find(@attachment_id)
    resource = attachment.record
    return redirect_to root_path, notice: I18n.t('notifications.cherry_request_stub') unless current_user.author_of?(resource)

    attachment.purge
  end
  # rubocop:enable Metrics/LineLength
end
