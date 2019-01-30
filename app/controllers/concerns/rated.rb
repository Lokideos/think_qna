# frozen_string_literal: true

module Rated
  extend ActiveSupport::Concern

  included do
    before_action :authorize_rating_action, only: %i[like unlike dislike]
  end

  # rubocop:disable Metrics/AbcSize
  def like
    respond_to do |format|
      if resource.rating.not_been_rated_this_way?(current_user, Rating::RATED_UP)
        resource.rating.score_up(current_user)
        format.json { render json: resource.rating }
      else
        format.json { render json: 'Already liked', status: :unprocessable_entity }
      end
    end
  end

  def dislike
    respond_to do |format|
      if resource.rating.not_been_rated_this_way?(current_user, Rating::RATED_DOWN)
        resource.rating.score_down(current_user)
        format.json { render json: resource.rating }
      else
        format.json { render json: 'Already disliked.', status: :unprocessable_entity }
      end
    end
  end

  def unlike
    respond_to do |format|
      if resource.rating.rated?(current_user)
        resource.rating.score_delete(current_user)
        format.json { render json: resource.rating }
      else
        format.json { render json: 'Not yet liked or disliked.', status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def authorize_rating_action
    authorize! action_name.to_sym, resource
  end

  def respond_with_error
    respond_to do |format|
      format.json { render json: "Can't be rated by author.", status: :unprocessable_entity }
    end
  end

  def resource
    controller_name.classify.constantize.with_attached_files.find(params[:id]) if params[:id]
  end
end
