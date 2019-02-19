# frozen_string_literal: true

class Search < ApplicationRecord
  SEARCH_TYPES = %w[Question Answer Comment].freeze

  validates :query, :search_type, presence: true
  validate :correct_search_type

  def perform_search
    search_type.capitalize.constantize.search(query)
  end

  private

  def correct_search_type
    errors.add(:search_type, 'has to be one of existing entities') unless SEARCH_TYPES.include?(search_type)
  end
end
