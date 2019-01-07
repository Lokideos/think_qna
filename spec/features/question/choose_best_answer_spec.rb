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

        within '.answers' do
          click_on(id: "choose-best-answer-link-#{answer.id}")
        end

        expect(page).to have_content 'You chose the best answer.'
        within '.best-answer' do
          expect(page).to_not have_content 'Other Answer Body'
          expect(page).to have_content answer.body
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

    scenario "tries to choose best answer for other user's question via PATCH request" do
      page.driver.submit :patch, "/answers/#{answer.id}", best: true

      expect(page).to have_content 'You can modify or delete only your resources.'
      expect(page).to_not have_content 'Updated by non author'
    end
  end

  context 'Unauthenticated user' do
    scenario 'tries to choose best answer', js: true do
      visit question_path(question)

      within '.answers' do
        expect(page).to_not have_link 'Best Answer'
      end
    end

    scenario 'tries to choose best answer via patch request' do
      page.driver.submit :patch, "/answers/#{answer.id}", best: true

      expect(page).to have_content 'You need to sign in or sign up before continuing.'
      expect(page).to_not have_content 'Updated by unauthenticated user'
    end
  end
end
# rubocop:enable Metrics/BlockLength
