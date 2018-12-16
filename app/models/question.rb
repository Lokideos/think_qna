# frozen_string_literal: true

class Question < ApplicationRecord
  validates :title, :body, presence: true
end
