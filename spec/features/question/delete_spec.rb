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
    click_on 'Delete Question'

    expect(page).to have_content('You have successfully deleted the question.')
    expect(page).to_not have_content question.title
  end

  context 'Non author user tries' do
    before { sign_in(non_author) }

    scenario "to delete other users' question" do
      visit question_path(question)

      expect(page).to_not have_content 'Delete Question'
    end

    scenario "to delete other users' question via delete request" do
      page.driver.submit :delete, "/questions/#{question.id}", {}

      expect(page).to have_content 'You can modify or delete only your questions'
    end
  end

  scenario 'Unauthenticated user tries to delete a question' do
    visit question_path(question)

    expect(page).to_not have_content 'Delete Question'
  end
end
