# frozen_string_literal: true

class Services::Search
  include ActiveModel::Validations

  SEARCH_TYPES = %w[Question Answer Comment User Global].freeze

  attr_accessor :query, :search_type

  def initialize(query, search_type)
    @query = query
    @search_type = search_type
  end

  validates :query, :search_type, presence: true
  validates :search_type, inclusion: { in: SEARCH_TYPES }

  def call
    search_type == 'Global' ? ThinkingSphinx.search(query) : search_type.capitalize.constantize.search(query)
  end
end
