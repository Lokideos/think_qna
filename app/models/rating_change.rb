# frozen_string_literal: true

class RatingChange < ApplicationRecord
  belongs_to :rating
  belongs_to :user

  validates :user, uniqueness: { scope: :rating, message: 'can like or dislike resource only once in a row.' }
end
