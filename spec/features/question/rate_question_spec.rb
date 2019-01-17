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

    background { visit question_path(question) }

    scenario 'rates up the question', js: true do
      within '.question-rating' do
        click_on 'Like'
      end
      wait_for_ajax
      sleep(2)

      within '.question-rating' do
        expect(page).to have_content 'Rating: 1'
      end

      expect(page).to have_content 'You have successfully rated the question.'
    end

    scenario 'rates down the question', js: true do
      within '.question-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax
      sleep(2)

      within '.question-rating' do
        expect(page).to have_content 'Rating: -1'
      end

      expect(page).to have_content 'You have successfully rated the question.'
    end

    scenario 'tries to rate question up second time', js: true do
      within '.question-rating' do
        click_on 'Like'
      end
      wait_for_ajax
      sleep(2)

      within '.question-rating' do
        expect(page).to have_content 'Rating: 1'
        expect(page).to_not have_link 'Like'
      end
    end

    scenario 'tries to rate question down second time', js: true do
      within '.question-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax
      sleep(2)

      within '.question-rating' do
        expect(page).to have_content 'Rating: -1'
        expect(page).to_not have_link 'Dislike'
      end
    end

    scenario 'see rating and does not see link to like the question after liking it and reloading the page' do
      within '.question-rating' do
        click_on 'Like'
      end
      page.evaluate_script 'window.location.reload()'
      wait_for_ajax
      sleep(2)

      within '.question-rating' do
        expect(page).to_not have_content 'Rating: 1'
        expect(page).to_not have_link 'Like'
      end
    end

    scenario 'see rating and does not see link to dislike the question after disliking it and reloading the page' do
      within '.question-rating' do
        click_on 'Dislike'
      end
      page.evaluate_script 'window.location.reload()'
      wait_for_ajax
      sleep(2)

      within '.question-rating' do
        expect(page).to_not have_content 'Rating: -1'
        expect(page).to_not have_link 'Dislike'
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
