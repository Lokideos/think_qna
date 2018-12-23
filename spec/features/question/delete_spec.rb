# frozen_string_literal: true

require 'rails_helper'

feature 'Author can delete his question', "
  In order to delete bad questions
  As an author of question
  I'd like to be able to delete my question
" do

  given(:author) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question, user: author) }

  scenario 'Author deletes his question' do
    sign_in(author)
    visit question_path(question)
    click_on 'Delete question'

    expect(page).to have_content('You have successfully deleted the question.')
    expect(page).to_not have_content question.title
  end

  scenario "User tries to delete other users' question" do
    sign_in(non_author)
    visit question_path(question)

    expect(page).to_not have_content 'Delete question'
  end

  scenario 'Unauthenticated user tries to delete a question' do
    visit question_path(question)

    expect(page).to_not have_content 'Delete question'
  end
end
