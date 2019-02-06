# frozen_string_literal: true

require 'rails_helper'

feature 'User can subscribe to question', "
  In order to get information about answers to the question faster
  As a user
  I'd like to be able to subscribe to questions to receive email notifications
" do
  given(:user) { create(:user) }
  given(:question) { create(:question, title: 'Question to subscribe') }

  scenario 'Authenticated user subscribes to the question', js: true do
    sign_in(user)
    visit question_path(question)

    within '.question' do
      click_on 'Subscribe'
    end

    expect(page).to_not have_link'Subscribe'
    expect(page).to have_content 'You have subscribed to question Question to subscribe'
  end

  scenario 'Unauthenticated user tries to subscribe to the question'
end
