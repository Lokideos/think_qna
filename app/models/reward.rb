# frozen_string_literal: true

class Reward < ApplicationRecord
  belongs_to :question
  belongs_to :user, optional: true

  has_one_attached :image, dependent: :destroy

  validates :title, presence: true
end
