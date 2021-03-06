# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'Author can create only his answers', "
  In order to delete only my answers
  As an author of the answer
  I'd like to be able to delete my answer
" do

  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, user: user) }

  context 'Authenticated user' do
    scenario 'deletes his answer', js: true do
      sign_in(user)
      visit question_path(question)

      within('.answers') { click_on 'Delete Answer' }

      expect(page).to have_content 'Answer has been successfully deleted.'
      expect(page).to_not have_content answer.body
    end

    context 'not as author of the answer' do
      before { sign_in(non_author) }

      scenario "tries to delete other user's answer", js: true do
        visit question_path(question)

        within('.answers') { expect(page).to_not have_link 'Delete Answer' }
      end
    end
  end

  context 'Unauthenticated user' do
    scenario 'tries to delete an answer', js: true do
      visit question_path(question)

      within('.answers') { expect(page).to_not have_link 'Delete Answer' }
    end
  end
end
# rubocop:enable Metrics/BlockLength
