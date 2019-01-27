# frozen_string_literal: true

class LinksController < ApplicationController
  before_action :authenticate_user!

  authorize_resource

  def destroy
    @link = Link.find(params[:id])
    unless current_user.author_of?(@link.linkable)
      return redirect_to root_path, notice: I18n.t('notifications.cherry_request_stub')
    end

    @link.destroy
  end
end
