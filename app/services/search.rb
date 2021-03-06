# frozen_string_literal: true

class Services::Search
  include ActiveModel::Validations

  SEARCH_TYPES = %w[Question Answer Comment User Global].freeze

  validates :query, :search_type, presence: true
  validates :search_type, inclusion: { in: SEARCH_TYPES }

  attr_accessor :query, :search_type

  def initialize(query, search_type)
    @query = query
    @search_type = search_type
  end

  def call
    raise StandardError, I18n.t('errors.invalid_search_attributes') unless valid?

    search_type == 'Global' ? ThinkingSphinx.search(query) : search_type.capitalize.constantize.search(query)
  end
end
