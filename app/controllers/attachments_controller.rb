# frozen_string_literal: true

class AttachmentsController < ApplicationController
  before_action :authenticate_user!

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/LineLength
  def destroy
    resource_id = params[:resource_id]
    resource_class = params[:resource_class]
    return redirect_to root_path unless Attachment.resource_permitted?(resource_class)

    resource = resource_class.constantize.find_by(id: resource_id)
    return redirect_to root_path, notice: I18n.t('notifications.cherry_request_stub') unless current_user.author_of?(resource)

    @attachment_id = params[:id]
    resource.files.find_by(id: @attachment_id).purge
  end
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/AbcSize
end
