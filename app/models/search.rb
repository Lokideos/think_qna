# frozen_string_literal: true

class Search < ApplicationRecord
  validates :query, presence: true
end
