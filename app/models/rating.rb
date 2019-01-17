# frozen_string_literal: true

class Rating < ApplicationRecord
  has_many :rating_changes
  has_many :users, through: :rating_changes
  belongs_to :ratable, polymorphic: true

  validates :score, presence: true

  def score_up(user)
    raise StandardError, "User can't rate his resources" if ratable_author == user

    Rating.transaction do
      increment(:score, 1)
      save
      users << user
    end
  end

  def score_down(user)
    raise StandardError, "User can't rate his resources" if ratable_author == user

    Rating.transaction do
      decrement(:score, 1)
      save
      users << user
    end
  end

  def rated_by?(user)
    users.find_by(id: user.id)
  end

  private

  def ratable_author
    ratable_type.classify.constantize.find(ratable_id).user
  end
end
