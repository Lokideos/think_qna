# frozen_string_literal: true

class Rating < ApplicationRecord
  has_many :rating_changes
  has_many :users, through: :rating_changes
  belongs_to :ratable, polymorphic: true

  validates :score, presence: true

  RATED_UP = 'liked'
  RATED_DOWN = 'disliked'

  def score_up(user)
    raise StandardError, "User can't rate his resources" if ratable_author == user

    Rating.transaction do
      rating_change_value(user)&.destroy
      users << user
      rating_change_value(user).update(status: RATED_UP)
      increment(:score, 1)
      save
    end
  end

  def score_down(user)
    raise StandardError, "User can't rate his resources" if ratable_author == user

    Rating.transaction do
      rating_change_value(user)&.destroy
      users << user
      rating_change_value(user).update(status: RATED_DOWN)
      decrement(:score, 1)
      save
    end
  end

  def rated_by?(user)
    users.find_by(id: user.id)
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
