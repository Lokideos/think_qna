# frozen_string_literal: true

module Ratable
  extend ActiveSupport::Concern
  included do
    after_save :create_rating
    has_one :rating, dependent: :destroy, as: :ratable

    private

    def create_rating
      Rating.create(ratable: self)
    end
  end
end
