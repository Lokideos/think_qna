# frozen_string_literal: true

class RatingChange < ApplicationRecord
  belongs_to :rating
  belongs_to :user

  validates :user, uniqueness: { scope: :rating, message: I18n.t('errors.like_duplicate') }
end
