# frozen_string_literal: true

require 'rails_helper'

feature 'User can add links to the question', "
  In order to provide additional information to my question
  As Author of the question
  I'd like to be able to add links to this question
" do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/Lokideos/815f3eea3f00a35ff48ea2984457b673' }

  scenario 'User adds link when he asks the question' do
    sign_in(user)
    visit new_question_path

    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'text text text'

    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Ask'

    expect(page).to have_link 'My gist', href: gist_url
  end
end
