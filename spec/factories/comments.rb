# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    body { 'New Comment Body' }
    commentable { |r| r.association(:question) }

    trait :invalid do
      body { nil }
    end
  end
end
