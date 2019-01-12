# frozen_string_literal: true

class Attachment < ApplicationRecord
  PERMITTED_RESOURCES = %w[Question Answer].freeze

  def self.resource_permitted?(resource_class)
    PERMITTED_RESOURCES.include?(resource_class)
  end
end
