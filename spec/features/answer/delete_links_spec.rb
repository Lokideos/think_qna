# frozen_string_literal: rue

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can delete links attached to his answer', "
  In order to keep links attached to my answer relevant
  As Author of answer
  I'd like to be able to delete links attached to my answer
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question) }
  given(:answer) { create(:answer, question: question, user: user) }
  given!(:link) do
    create(:link, name: 'Gist Link',
                  url: 'https://gist.github.com/CarrierTestApplication/18d658003f43d86e292aefa67e8de58a',
                  linkable: answer)
  end

  scenario 'Author deletes link attached to his answer', js: true do
    sign_in(user)
    visit question_path(question)

    within '.answers' do
      click_on 'Delete Link'
    end

    within '.answers' do
      expect(page).to_not have_link link.name
    end
    expect(page).to have_content 'You have successfully deleted link.'
  end

  scenario "User tries to delete link attached to other user's answer" do
    sign_in(non_author)
    visit question_path(question)

    within '.answers' do
      expect(page).to_not have_link 'Delete Link'
    end
  end

  scenario 'Unauthenticated user tries to delete link attached to answer' do
    visit question_path(question)

    within '.answers' do
      expect(page).to_not have_link 'Delete Link'
    end
  end
end
# rubocop:enable Metrics/BlockLength
