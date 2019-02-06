# frozen_string_literal: true

require 'rails_helper'

feature 'User can subscribe to question', "
  In order to get information about answers to the question faster
  As a user
  I'd like to be able to subscribe to questions to receive email notifications
" do
  given(:user) { create(:user) }
  given(:question) { create(:question, title: 'Question to subscribe') }

  context 'Authenticated user' do
    before { sign_in(user) }

    scenario 'subscribes to the question', js: true do
      visit question_path(question)

      within '.question' do
        click_on 'Subscribe'
      end

      expect(page).to_not have_link 'Subscribe'
    end

    scenario 'tries to subscribe to question if he is already subscribed to it', js: true do
      visit question_path(question)

      within '.question' do
        click_on 'Subscribe'
      end

      visit question_path(question)

      expect(page).to_not have_link 'Subscribe'
    end
  end

  scenario 'Unauthenticated user tries to subscribe to the question' do
    visit question_path(question)

    expect(page).to_not have_link 'Subscribe'
  end
end
