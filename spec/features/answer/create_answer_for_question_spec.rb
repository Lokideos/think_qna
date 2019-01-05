# frozen_string_literal: true

require 'rails_helper'

feature 'User can create answer for the question', "
  In order to solve the requested issue
  As authenticated user
  I'd like to be able to answer the question on its page
" do

  given(:question) { create(:question) }
  given(:user) { create(:user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)

      visit question_path(question, lang: 'en')
    end

    scenario 'create answer for the question' do
      fill_in 'Body', with: 'Answer text'
      click_on 'Answer on question'

      expect(page).to have_content 'Answer was successfully created.'
      expect(page).to have_content 'Answer text'
    end

    scenario 'tries to create answer with wrong parameters for the question' do
      click_on 'Answer on question'

      expect(page).to have_content "Answer wasn't created; check your input."
      expect(page).to have_content "Body can't be blank"
    end
  end

  scenario 'Unauthenticated user tries to create answer for the question' do
    visit question_path(question, lang: 'en')

    within('.new_answer') { expect(page).to_not have_content 'Body' }
  end
end
