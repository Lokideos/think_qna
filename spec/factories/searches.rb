# frozen_string_literal: true

FactoryBot.define do
  factory :search do
    query { 'my_query_request' }
    search_type { 'Question' }

    trait :invalid do
      query { nil }
    end
  end
end
