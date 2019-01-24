# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'Author of comment to answer can delete his comment', "
  In order to clarify my reactions to answer
  As an Author of comment to answer
  I'd like to be able to delete this comment
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer, question: question) }
  given!(:comment) { create(:comment, body: 'Comment Body', commentable: answer, user: user) }

  scenario 'Author deletes his comment to answer', js: true do
    sign_in(user)
    visit question_path(question)

    within '.answers .answer-comments' do
      click_on 'Delete Comment'
    end

    within '.answers .answer-comments' do
      expect(page).to_not have_content 'Comment Body'
    end
  end

  scenario "User tries to delete other user's comment to answer" do
    sign_in(non_author)
    visit question_path(question)

    within '.answers .answer-comments' do
      expect(page).to_not have_link 'Delete Comment'
    end
  end

  scenario 'Unauthenticated user tries to delete comment to answer' do
    visit question_path(question)

    within '.answers .answer-comments' do
      expect(page).to_not have_link 'Delete Comment'
    end
  end
end
# rubocop:enable Metrics/BlockLength
