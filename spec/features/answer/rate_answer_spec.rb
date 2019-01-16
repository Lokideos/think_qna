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
  given(:answer) { create(:answer, question: question, user: answer_author) }
  given!(:rating) { create(:rating, ratable: answer) }

  context 'Authenticated user and not Author of the answer', js: true do
    background { sign_in(user) }

    scenario 'rate up the answer' do
      visit question_path(question)

      within '.answers .answer-rating' do
        click_on 'Like'
      end

      within '.answers .answer-rating' do
        expect(page).to have_content 'Rating: 1'
      end

      expect(page).to have_content 'You have successfully rated the answer.'
    end

    scenario 'rate down the answer', js: true do
      visit question_path(question)

      within '.answers .answer-rating' do
        click_on 'Dislike'
      end

      within '.answers .answer-rating' do
        expect(page).to have_content 'Rating: -1'
      end

      expect(page).to have_content 'You have successfully rated the answer.'
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
