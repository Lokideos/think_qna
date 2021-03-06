# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can add links to answer', "
  In order to provide additional information to my answer
  As Author of the answer
  I'd like to be able to add links to this answer
" do
  given(:user) { create(:user) }
  given(:question) { create(:question) }
  given(:gist_url) { 'https://gist.github.com/Lokideos/815f3eea3f00a35ff48ea2984457b673' }
  given(:google_url) { 'https://google.ru' }

  background do
    sign_in(user)
    visit question_path(question)

    within'.new-answer' do
      fill_in 'Body', with: 'New Answer Text'
    end
  end

  scenario 'User adds link when he answers the questions', js: true do
    within '.new-answer' do
      fill_in 'Link name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'Answer to question'
    end

    within '.answers' do
      expect(page).to have_link 'My gist', href: gist_url
    end
  end

  scenario 'User tries to add link with bad url address', js: true do
    within '.new-answer' do
      fill_in 'Link name', with: 'Bad URL'
      fill_in 'Url', with: 'bad url'

      click_on 'Answer to question'
    end

    within '.answers' do
      expect(page).to_not have_link 'Bad URL'
    end

    within '.new-answer' do
      expect(page).to have_content 'Links url should be correct url address.'
    end
  end

  scenario 'User adds multiple links when he answers the question', js: true do
    within '.new-answer' do
      fill_in 'Link name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'add link'

      within '.nested-fields' do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: google_url
      end

      click_on 'Answer to question'
    end

    within '.answers' do
      expect(page).to have_link 'My gist', href: gist_url
      expect(page).to have_link 'Google', href: google_url
    end
  end

  scenario 'User does not see filled in link name and link url after he creates an answer with links', js: true do
    within '.new-answer' do
      fill_in 'Link name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'add link'

      within '.nested-fields' do
        fill_in 'Link name', with: 'Google'
        fill_in 'Url', with: google_url
      end

      click_on 'Answer to question'
    end

    within '.new-answer' do
      expect(page).to_not have_content 'My gist'
      expect(page).to_not have_content gist_url
      expect(page).to_not have_link 'Google'
      expect(page).to_not have_content google_url
    end
  end

  scenario 'If link leads to gist show gist in addition to link', js: true do
    within '.new-answer' do
      fill_in 'Link name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'Answer to question'
    end

    wait_for_ajax

    within '.answers' do
      expect(page).to have_content 'Hello Gist!'
    end
  end
end
# rubocop:enable Metrics/BlockLength
