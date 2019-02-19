# frozen_string_literal: true

require 'sphinx_helper'

feature 'User can search for user', "
  In order to find needed user
  As a User
  I'd like to be able to search for the user
" do
  given!(:user_1) { create(:user, email: 'email@first.com') }
  given!(:user_2) { create(:user, email: 'email@second.com') }

  scenario 'User searches for the user', sphinx: true do
    visit questions_path
    ThinkingSphinx::Test.run do
      within '.search' do
        fill_in 'Search', with: 'first.com'
        select 'User', from: 'Search Type'
        click_on 'Find'
      end

      expect(page).to have_content 'email@first.com'
      expect(page).to have_content 'Search Results'
      expect(page).to_not have_content 'email@second.com'
    end
  end
end
