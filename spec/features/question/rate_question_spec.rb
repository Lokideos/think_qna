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

  context 'Authenticated user and not author of the question' do
    background { sign_in(user) }

    background { visit question_path(question) }

    scenario 'rates up the question', js: true do
      within '.question-rating' do
        click_on 'Like'
      end
      wait_for_ajax

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: 1'
      end
    end

    scenario 'rates down the question', js: true do
      within '.question-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: -1'
      end
    end

    scenario 'tries to rate question up second time', js: true do
      within '.question-rating' do
        click_on 'Like'
      end
      wait_for_ajax

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: 1'
        expect(page).to_not have_link 'Like'
      end
    end

    scenario 'tries to rate question down second time', js: true do
      within '.question-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax

      within '.question-rating .question-rating-value' do
        expect(page).to have_content 'Rating: -1'
        expect(page).to_not have_link 'Dislike'
      end
    end

    scenario 'sees the unlike link after he rates the question', js: true do
      within '.question' do
        click_on 'Like'
      end

      within '.question-rating' do
        expect(page).to have_link 'Unlike'
      end
    end

    scenario 'unlikes the quesiton, see rating and does not see unlike link', js: true do
      within '.question' do
        click_on 'Like'
        wait_for_ajax
        click_on 'Unlike'
      end

      within '.question-rating' do
        expect(page).to_not have_link 'Unlike'
        expect(page).to have_content 'Rating: 0'
      end
    end
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
