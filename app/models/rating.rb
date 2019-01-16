# frozen_string_literal: true

class Rating < ApplicationRecord
  belongs_to :question

  validates :score, presence: true

  def score_up
    increment(:score, 1)
    save
  end

  def score_down
    decrement(:score, 1)
    save
  end
end
