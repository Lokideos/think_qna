# frozen_string_literal: true

module Ratable
  extend ActiveSupport::Concern
  included do
    after_save :create_related_rating
    has_one :rating, dependent: :destroy, as: :ratable

    private

    def create_related_rating
      create_rating
    end
  end
end
