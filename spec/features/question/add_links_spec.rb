# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can add links to the question', "
  In order to provide additional information to my question
  As Author of the question
  I'd like to be able to add links to this question
" do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/Lokideos/815f3eea3f00a35ff48ea2984457b673' }
  given(:google_url) { 'https://google.ru' }

  background do
    sign_in(user)
    visit new_question_path

    within '.question-info' do
      fill_in 'Title', with: 'Test question'
      fill_in 'Body', with: 'text text text'
    end
  end

  scenario 'User adds link when he asks the question' do
    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Ask'

    expect(page).to have_link 'My gist', href: gist_url
  end

  scenario 'User tries to add link with bad url address' do
    fill_in 'Link name', with: 'Bad URL'
    fill_in 'Url', with: 'bad url'

    click_on 'Ask'

    expect(page).to_not have_link 'Bad URL'
    expect(page).to have_content 'Links url should be correct url address.'
  end

  scenario 'User adds several links when he asks the question', js: true do
    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'add link'

    within '.nested-fields' do
      fill_in 'Link name', with: 'Google'
      fill_in 'Url', with: google_url
    end

    click_on 'Ask'

    expect(page).to have_link 'My gist', href: gist_url
    expect(page).to have_link 'Google', href: google_url
  end

  scenario 'If link leads to gist show gist in addition to link' do
    fill_in 'Link name', with: 'My gist'
    fill_in 'Url', with: gist_url

    click_on 'Ask'

    expect(page).to have_content 'Hello Gist!'
  end
end
# rubocop:enable Metrics/BlockLength
