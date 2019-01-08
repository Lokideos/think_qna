# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can update his question', "
  In order to correct mistakes or to specify the question
  As a User
  I'd like to be able to update my question
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question, user: user) }

  context 'Authenticated User' do
    context 'and Author of the question' do
      background do
        sign_in(user)

        visit question_path(question)
        click_on 'Edit Question'
      end

      scenario 'updates the question', js: true do
        within '.question' do
          fill_in 'Title', with: 'Updated Question'
          click_on 'Update'
        end

        expect(page).to have_content 'Your Question has been successfully updated.'
        expect(page).to have_content 'Updated Question'
      end

      scenario 'tries to update the question with invalid attributes', js: true do
        within '.question' do
          fill_in 'Title', with: ''
          click_on 'Update'
        end

        expect(page).to have_content 'There were errors in your input.'
        within '.question' do
          expect(page).to have_content "Title can't be blank"
        end
      end
    end

    context 'but non Author of the question' do
      background do
        sign_in(non_author)
      end

      scenario "tries to update other user's question", js: true do
        visit question_path(question)

        expect(page).to_not have_link 'Edit Question'
      end
    end
  end

  context 'Unauthenticated User' do
    scenario 'tries to update the question', js: true do
      visit question_path(question)

      expect(page).to_not have_link 'Edit Question'
    end
  end
end
# rubocop:enable Metrics/BlockLength
