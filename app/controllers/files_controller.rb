# frozen_string_literal: true

class FilesController < ApplicationController
  before_action :authenticate_user!

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/LineLength
  # rubocop:disable Security/Eval
  def destroy
    permitted_resources = %w[Question Answer]
    resource_id = params[:resource_id]
    resource_class = params[:resource_class]
    return redirect_to root_path unless resource_class.is_a?(String) && permitted_resources.include?(resource_class)

    resource = eval(resource_class).find_by(id: resource_id)
    return redirect_to root_path, notice: I18n.t('notifications.cherry_request_stub') unless current_user.author_of?(resource)

    @file_id = params[:id]
    resource.files.find_by(id: @file_id).purge
  end
  # rubocop:enable Security/Eval
  # rubocop:enable Metrics/LineLength
  # rubocop:enable Metrics/AbcSize
end
