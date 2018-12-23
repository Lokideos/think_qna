# frozen_string_literal: true

FactoryBot.define do
  sequence :body do |n|
    "AnswerBody#{n}"
  end

  factory :answer do
    question
    body

    trait :invalid do
      body { nil }
    end
  end
end
