# frozen_string_literal: truee

FactoryBot.define do
  sequence :body do |n|
    "AnswerBody#{n}"
  end

  factory :answer do
    user
    question
    body
    best { false }

    trait :invalid do
      body { nil }
    end
  end
end
