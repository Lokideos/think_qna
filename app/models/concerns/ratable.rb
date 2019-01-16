# frozen_string_literal: true

module Ratable
  extend ActiveSupport::Concern
  included do
    has_one :rating, dependent: :destroy, as: :ratable
  end
end
