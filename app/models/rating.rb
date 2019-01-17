# frozen_string_literal: true

class Rating < ApplicationRecord
  has_many :rating_changes
  has_many :users, through: :rating_changes
  belongs_to :ratable, polymorphic: true

  validates :score, presence: true

  RATED_UP = 'liked'
  RATED_DOWN = 'disliked'

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def score_up(user)
    raise StandardError, "User can't rate his resources" if ratable_author == user

    if rating_change_value(user)
      increment(:score, 1) if rating_change_value(user).status == RATED_DOWN
      rating_change_value(user).destroy
    end

    Rating.transaction do
      users << user
      rating_change_value(user).update(status: RATED_UP)
      increment(:score, 1)
      save
    end
  end

  def score_down(user)
    raise StandardError, "User can't rate his resources" if ratable_author == user

    if rating_change_value(user)
      decrement(:score, 1) if rating_change_value(user).status == RATED_UP
      rating_change_value(user).destroy
    end

    Rating.transaction do
      users << user
      rating_change_value(user).update(status: RATED_DOWN)
      decrement(:score, 1)
      save
    end
  end

  def score_delete(user)
    status = rating_changes.where(rating_id: self, user_id: user).first.status

    if status == RATED_UP
      decrement(:score, 1)
      save
    elsif status == RATED_DOWN
      increment(:score, 1)
      save
    end

    rating_changes.where(rating_id: self, user_id: user).first.delete
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def rated?(user)
    rating_changes.where(rating_id: self, user_id: user).first
  end

  def ratable?(user, value)
    !rating_changes.where(rating_id: self, user_id: user, status: value).first
  end

  private

  def rating_change_value(user)
    rating_changes.where(rating_id: self, user_id: user).first
  end

  def ratable_author
    ratable_type.classify.constantize.find(ratable_id).user
  end
end
