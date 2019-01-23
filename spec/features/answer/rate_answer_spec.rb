# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can rate the answer', "
  In order to choose great answers
  As not an Author of the answer
  I'd like to be able to rate the answer
" do
  given(:user) { create(:user) }
  given(:answer_author) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, user: answer_author) }

  context 'Authenticated user and not Author of the answer' do
    background { sign_in(user) }

    background { visit question_path(question) }

    scenario 'rate up the answer', js: true do
      within '.answers .answer-rating' do
        click_on 'Like'
      end
      wait_for_ajax

      within '.answers .answer-rating' do
        expect(page).to have_content 'Rating: 1'
      end
    end

    scenario 'rate down the answer', js: true do
      within '.answers .answer-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax

      within '.answers .answer-rating' do
        expect(page).to have_content 'Rating: -1'
      end
    end

    scenario 'tries to rate answer up second time', js: true do
      within '.answers .answer-rating' do
        click_on 'Like'
      end
      wait_for_ajax

      within '.answers .answer-rating' do
        expect(page).to have_content 'Rating: 1'
        expect(page).to_not have_link 'Like'
      end
    end

    scenario 'tries to rate answer down second time', js: true do
      within '.answers .answer-rating' do
        click_on 'Dislike'
      end
      wait_for_ajax

      within '.answers .answer-rating' do
        expect(page).to have_content 'Rating: -1'
        expect(page).to_not have_link 'Dislike'
      end
    end

    scenario 'unlikes the answer, see rating and does not see unlike link', js: true do
      within '.answers .answer-rating' do
        click_on 'Like'
        wait_for_ajax
        click_on 'Unlike'
      end

      within '.answers .answer-rating' do
        expect(page).to_not have_link 'Unlike'
      end

      within '.answers .answer-rating' do
        expect(page).to have_content 'Rating: 0'
      end
    end
  end

  scenario 'Author tries to rate his answer' do
    sign_in(answer_author)
    visit question_path(question)

    within '.answers .answer-rating' do
      expect(page).to_not have_link 'Like'
    end
  end

  scenario 'Unauthenticated user tries to rate his answer' do
    visit question_path(question)

    within '.answers .answer-rating' do
      expect(page).to_not have_link 'Like'
    end
  end
end
# rubocop:enable Metrics/BlockLength
