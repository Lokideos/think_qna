# frozen_string_literal: rue

require 'rails_helper'

feature 'User can delete links attached to his question', "
  In order to keep links attached to my question relevant
  As Author of question
  I'd like to be able to delete links attached to my question
" do
  given(:user) { create(:user) }
  given(:non_author) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:link) do
    create(:link, name: 'Gist Link',
                  url: 'https://gist.github.com/CarrierTestApplication/18d658003f43d86e292aefa67e8de58a',
                  linkable: question)
  end

  scenario 'Author deletes link attached to his question', js: true do
    sign_in(user)
    visit question_path(question)

    click_on 'Delete Link'

    expect(page).to_not have_link link.name
    expect(page).to have_content 'You have successfully deleted link.'
  end

  scenario "User tries to delete link attached to other user's question" do
    sign_in(non_author)
    visit question_path(question)

    expect(page).to_not have_link 'Delete Link'
  end

  scenario 'Unauthenticated user tries to delete link attached to question' do
    visit question_path(question)

    expect(page).to_not have_link 'Delete Link'
  end
end
