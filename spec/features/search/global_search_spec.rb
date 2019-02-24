# frozen_string_literal: true

require 'sphinx_helper'

feature 'User can perform global search', "
  In order to find needed information
  As a User
  I'd like to be able to search for anything with given query string
" do
  given!(:question) { create(:question, title: 'Shared Info 1') }
  given!(:answer) { create(:answer, body: 'Shared Info 1') }
  given!(:answer_2) { create(:answer, body: 'Bad info') }

  scenario 'User searches for the needed information globally', sphinx: true do
    visit questions_path
    ThinkingSphinx::Test.run do
      within '.search' do
        fill_in 'Search', with: 'Shared'
        select 'Global', from: 'Search Type'
        click_on 'Find'
      end

      2.times { expect(page).to have_content 'Shared Info 1' }
      expect(page).to have_content 'Search Results'
      expect(page).to_not have_content 'Bad info'
    end
  end
end
