# frozen_string_literal: true

class Rating < ApplicationRecord
  has_many :rating_changes
  has_many :users, through: :rating_changes
  belongs_to :ratable, polymorphic: true, touch: true

  validates :score, presence: true

  RATED_UP = 'liked'
  RATED_DOWN = 'disliked'

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def score_up(user)
    check_user(user)

    Rating.transaction do
      if rating_change_value(user)
        increment!(:score, 1) if rating_change_value(user).status == RATED_DOWN
        rating_change_value(user).destroy!
        @rating_change_value = nil
      end

      users << user
      rating_change_value(user).update!(status: RATED_UP)
      increment!(:score, 1)
      save!
    end
  end

  def score_down(user)
    check_user(user)

    Rating.transaction do
      if rating_change_value(user)
        decrement!(:score, 1) if rating_change_value(user).status == RATED_UP
        rating_change_value(user).destroy!
        @rating_change_value = nil
      end

      users << user
      rating_change_value(user).update!(status: RATED_DOWN)
      decrement!(:score, 1)
      save!
    end
  end

  def score_delete(user)
    check_user(user)

    status = rating_changes.find_by(user: user).status

    if status == RATED_UP
      decrement(:score, 1)
      save
    elsif status == RATED_DOWN
      increment(:score, 1)
      save
    end

    rating_changes.where(user: user).first.delete
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def rated?(user)
    rating_change_value(user).present?
  end

  def not_been_rated_this_way?(user, value)
    !rating_changes.where(user: user, status: value).first
  end

  private

  def check_user(user)
    raise StandardError, I18n.t('errors.resource_ownership') if user.author_of?(ratable)
  end

  def rating_change_value(user)
    @rating_change_value ||= rating_changes.find_by(user: user)
  end
end
