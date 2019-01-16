# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    score { 0 }
    question
  end
end
