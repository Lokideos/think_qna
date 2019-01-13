# frozen_string_literal: true

class Link < ApplicationRecord
  belongs_to :question

  validates :name, :url, presence: true
end
