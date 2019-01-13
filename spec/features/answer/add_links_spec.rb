# frozen_string_literal: true

require 'rails_helper'

feature 'User can add links to answer', "
  In order to provide additional information to my answer
  As Author of the answer
  I'd like to be able to add links to this answer
" do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:gist_url) { 'https://gist.github.com/Lokideos/815f3eea3f00a35ff48ea2984457b673' }

  scenario 'User adds link when he answers the questions', js: true do
    sign_in(user)
    visit question_path(question)

    within'.new-answer' do
      fill_in 'Body', with: 'New Answer Text'

      fill_in 'Link name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'Answer to question'
    end

    within '.answers' do
      expect(page).to have_link 'My gist', href: gist_url
    end
  end
end
