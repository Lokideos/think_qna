# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :authenticate_user!

  # rubocop:disable Metrics/LineLength
  def destroy
    @attachment_id = params[:id]
    attachment = ActiveStorage::Attachment.find_by(id: @attachment_id)
    resource = attachment.record_type.constantize.find_by(id: attachment.record_id)
    return redirect_to root_path, notice: I18n.t('notifications.cherry_request_stub') unless current_user.author_of?(resource)

    attachment.purge
  end
  # rubocop:enable Metrics/LineLength
end
