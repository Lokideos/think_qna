# frozen_string_literal: true

FactoryBot.define do
  factory :link do
    name { 'Link Name' }
    url { 'https://google.ru' }
  end
end
