# frozen_string_literal: true

class Answer < ApplicationRecord
  validates :body, presence: true
end
