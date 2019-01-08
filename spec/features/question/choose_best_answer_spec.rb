# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can choose best answer', "
  In order to clarify what answer was the most correct one
  As a User
  I'd like to be able to choose best answer
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:other_question) { create(:question, user: non_author) }
  given!(:answer) { create(:answer, question: question, user: non_author) }
  given(:other_answer) { create(:answer, question: other_question, user: user) }

  scenario 'Any user visit question and see best answer' do
    best_answer = create(:answer, question: question, best: true)
    visit question_path(question)

    within '.best-answer' do
      expect(page).to have_content best_answer.body
      expect(page).to_not have_link 'Best Answer'
    end

    within '.answers-list' do
      expect(page).to_not have_content best_answer.body
    end
  end

  context 'Authenticated user' do
    background { sign_in(user) }

    context 'in his question' do
      background { visit question_path(question) }

      scenario 'choose best answer', js: true do
        within '.answers' do
          click_on 'Best Answer'
        end

        expect(page).to have_content 'You chose the best answer.'
        within '.best-answer' do
          expect(page).to have_content answer.body
        end
      end

      scenario 'tries to choose best answer, when the question already has best answer', js: true do
        create(:answer, body: 'Other Answer Body', question: question, best: true)
        visit question_path(question)

        within '.answers' do
          click_on(id: "choose-best-answer-link-#{answer.id}")
        end

        expect(page).to have_content 'You chose the best answer.'
        within '.best-answer' do
          expect(page).to_not have_content 'Other Answer Body'
          expect(page).to have_content answer.body
        end

        within '.answers-list' do
          expect(page).to_not have_content answer.body
          expect(page).to have_content 'Other Answer Body'
        end
      end
    end

    scenario "tries to choose best answer for other user's question", js: true do
      create(:answer, question: other_question, user: user)
      visit question_path(other_question)

      within '.answers' do
        expect(page).to_not have_link 'Best Answer'
      end
    end
  end

  context 'Unauthenticated user' do
    scenario 'tries to choose best answer', js: true do
      visit question_path(question)

      within '.answers' do
        expect(page).to_not have_link 'Best Answer'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
