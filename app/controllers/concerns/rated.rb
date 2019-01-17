# frozen_string_literal: true

module Rated
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def like
    if current_user&.author_of?(resource)
      return respond_to do |format|
        format.json { render json: "Can't be liked by author.", status: :unprocessable_entity }
      end
    end

    respond_to do |format|
      if !resource.rating.rated_by?(current_user)
        resource.rating.score_up(current_user)
        format.json { render json: resource.rating }
      else
        format.json { render json: 'Already liked', status: :unprocessable_entity }
      end
    end
  end

  def dislike
    if current_user&.author_of?(resource)
      return respond_to do |format|
        format.json { render json: "Can't be liked by author.", status: :unprocessable_entity }
      end
    end

    respond_to do |format|
      if !resource.rating.rated_by?(current_user)
        resource.rating.score_down(current_user)
        format.json { render json: resource.rating }
      else
        format.json { render json: 'Already disliked.', status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def resource
    controller_name.classify.constantize.with_attached_files.find(params[:id]) if params[:id]
  end
end
