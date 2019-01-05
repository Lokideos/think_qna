# frozen_string_literal: true

FactoryBot.define do
  sequence :title do |n|
    "QuestionTitle#{n}"
  end

  factory :question do
    title
    body { 'QuestionBody' }
    user

    trait :invalid do
      title { nil }
    end
  end
end
