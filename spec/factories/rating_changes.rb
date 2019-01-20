# frozen_string_literal: true

FactoryBot.define do
  factory :rating_change do
    user
    rating
  end
end
