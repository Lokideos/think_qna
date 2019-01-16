# frozen_string_literal: true

module Rated
  extend ActiveSupport::Concern

  def like
    resource.rating.score_up

    respond_to do |format|
      format.json { render json: resource.rating }
    end
  end

  private

  def resource
    controller_name.classify.constantize.with_attached_files.find(params[:id]) if params[:id]
  end
end
