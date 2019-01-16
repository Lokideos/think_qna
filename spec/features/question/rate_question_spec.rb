# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can rate the question', "
  In order to determine most requested questions
  As a User who is not author of this question
  I'd like to be able rate the question
" do
  given(:user) { create(:user) }
  given(:question_author) { create(:user) }
  given(:question) { create(:question, user: question_author) }
  given!(:rating) { create(:rating, ratable: question) }

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

  scenario 'Author of the question tries to rate the question' do
    sign_in(question_author)
    visit question_path(question)

    within '.question-rating' do
      expect(page).to_not have_link 'Like'
    end
  end

  scenario 'Unauthenticated user tries to rate the question' do
    visit question_path(question)

    within '.question-rating' do
      expect(page).to_not have_link 'Like'
    end
  end
end
# rubocop:enable Metrics/BlockLength
