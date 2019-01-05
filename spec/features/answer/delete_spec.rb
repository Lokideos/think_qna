# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
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
    within('.answers') { click_on 'Delete Answer' }

    expect(page).to have_content 'Answer has been successfully deleted.'
    expect(page).to_not have_content answer.body
  end

  context 'Non author user triest' do
    before { sign_in(non_author) }

    scenario "to delete other users' answer" do
      visit question_path(question)

      within('.answers') { expect(page).to_not have_link 'Delete Answer' }
    end

    scenario "to delete other user's answer via delete request" do
      page.driver.submit :delete, "answers/#{answer.id}", {}

      expect(page).to have_content 'You can modify or delete only your answers'
    end
  end

  scenario 'Guest tries to delete an answer' do
    visit question_path(question)

    within('.answers') { expect(page).to_not have_link 'Delete Answer' }
  end
end
# rubocop:enable Metrics/BlockLength
