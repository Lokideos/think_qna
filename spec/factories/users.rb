# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "user#{n}@test.com"
  end

  factory :user do
    email
    confirmed_at DateTime.new(2018, 12, 12, 1, 1, 1)
    password { '12345678' }
    password_confirmation { '12345678' }
  end
end
