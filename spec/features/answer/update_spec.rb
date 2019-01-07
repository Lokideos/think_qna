# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can update his answer', "
  In order to correct or specify the answer
  As a User
  I'd like to be able to update my answer
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, user: user) }

  context 'Authenticated user' do
    context 'as author of answer' do
      background do
        sign_in(user)

        visit question_path(question)
      end

      scenario 'updates his answer', js: true do
        within '.answers' do
          click_on 'Edit Answer'

          fill_in 'Body', with: 'Updated Answer'
          click_on 'Update'
        end

        expect(current_path).to eq question_path(question)
        expect(page).to have_content 'Answer has been successfully updated.'
        within '.answers' do
          expect(page).to have_content 'Updated Answer'
        end
      end

      scenario 'tries to update his answer with invalid attributes', js: true do
        within '.answers' do
          click_on 'Edit Answer'

          fill_in 'Body', with: ''
          click_on 'Update'
        end

        expect(current_path).to eq question_path(question)
        expect(page).to have_content 'There were errors in your input.'
        within '.answers' do
          expect(page).to have_content "Body can't be blank"
        end
      end
    end

    context 'not as Author of answer' do
      background { sign_in(non_author) }

      scenario "tries to update other user's answer", js: true do
        visit question_path(question)

        within '.answers' do
          expect(page).to_not have_link 'Edit Answer'
        end
      end

      scenario "tries to update other user's answer via PATCH request" do
        page.driver.submit :patch, "/answers/#{answer.id}", body: 'Updated by non author'

        expect(page).to have_content 'You can modify or delete only your answers'
        expect(page).to_not have_content 'Updated by non author'
      end
    end
  end

  context 'Unauthenticated user' do
    scenario 'tries to update answer' do
      visit question_path(question)

      within '.answers' do
        expect(page).to_not have_link 'Edit Answer'
      end
    end

    scenario 'tries to update answer via PATCH request' do
      page.driver.submit :patch, "/answers/#{answer.id}", body: 'Updated by non author'

      expect(page).to have_content 'You need to sign in or sign up before continuing.'
      expect(page).to_not have_content 'Updated by non author'
    end
  end
end
# rubocop:enable Metrics/BlockLength
