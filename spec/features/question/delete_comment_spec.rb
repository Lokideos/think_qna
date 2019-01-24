# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'Authenticated user deletes his comment', "
  In order to coorect my mistakes
  As an Authenticated user
  I'd like to be able to delete my comments
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question) }
  given!(:comment) { create(:comment, body: 'Comment Body', commentable: question, user: user) }

  context 'Authenticated user' do
    scenario 'deletes his comment', js: true do
      sign_in(user)
      visit question_path(question)

      within '.question-comments' do
        click_on 'Delete Comment'
      end

      within '.question-comments' do
        expect(page).to_not have_content 'Comment Body'
      end
    end

    scenario "tries to delete other user's comment" do
      sign_in(non_author)
      visit question_path(question)

      within '.question-comments' do
        expect(page).to have_content 'Comment Body'
        expect(page).to_not have_link 'Delete Comment'
      end
    end
  end

  scenario 'Unauthenticated user tries to delete the comment' do
    visit question_path(question)

    within '.question-comments' do
      expect(page).to have_content 'Comment Body'
      expect(page).to_not have_link 'Delete Comment'
    end
  end
end
# rubocop:enable Metrics/BlockLength
