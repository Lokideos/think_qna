# frozen_string_literal: true

require 'rails_helper'

feature 'User can rate the question', "
  In order to determine most requested questions
  As a User who is not author of this question
  I'd like to be able rate the question
" do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given!(:rating) { create(:rating, question: question) }

  context 'Authenticated user and not author of the question' do
    background { sign_in(user) }

    scenario 'rates up the question', js: true do
      visit question_path(question)

      within '.question-rating' do
        click_on 'Like'
      end

      within '.question-rating' do
        expect(page).to have_content 'Rating: 1'
      end

      expect(page).to have_content 'You have successfully rated the question.'
    end

    scenario 'rates down the question'
  end

  scenario 'Author of the question tries to rate the question'

  scenario 'Unauthenticated user tries to rate the question'
end
