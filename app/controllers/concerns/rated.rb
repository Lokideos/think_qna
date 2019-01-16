# frozen_string_literal: true

module Rated
  extend ActiveSupport::Concern

  def like
    respond_to do |format|
      if !current_user.author_of?(resource)
        resource.rating.score_up
        format.json { render json: resource.rating }
      else
        format.json { render json: "Can't be modified", status: :unprocessable_entity }
      end
    end
  end

  private

  def resource
    controller_name.classify.constantize.with_attached_files.find(params[:id]) if params[:id]
  end
end
