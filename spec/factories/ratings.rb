# frozen_string_literal: true

FactoryBot.define do
  factory :rating do
    score { 0 }
    ratable { |r| r.association(:question) }
  end
end
