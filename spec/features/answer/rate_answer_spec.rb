# frozen_string_literal: true

require 'rails_helper'

feature 'User can rate the answer', "
  In order to choose great answers
  As not an Author of the answer
  I'd like to be able to rate the answer
" do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer, question: question) }
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

    scenario 'rate down the answer'
  end

  scenario 'Author tries to rate his answer'
  scenario 'Unauthenticated user tries to rate his answer'
end
