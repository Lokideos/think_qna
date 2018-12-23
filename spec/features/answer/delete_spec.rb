# frozen_string_literal: true

require 'rails_helper'

feature 'Author can create only his answers', "
  In order to delete only my answers
  As an author of the answer
  I'd like to be able to delete my answer
" do

  given(:author) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question) }
  given!(:answer) { create(:answer, question: question, user: author) }

  scenario 'Author deletes his answer' do
    sign_in(author)
    visit question_path(question)
    within('.answers') { click_on 'Delete answer' }

    expect(page).to have_content 'Answer has been successfully deleted.'
    expect(page).to_not have_content answer.body
  end

  scenario "Authenticated user tries to delete other users' answer" do
    sign_in(non_author)
    visit question_path(question)

    within('.answers') { expect(page).to_not have_content 'Delete answer' }
  end

  scenario 'Guest tries to delete an answer' do
    visit question_path(question)

    within('.answers') { expect(page).to_not have_content 'Delete answer' }
  end
end
