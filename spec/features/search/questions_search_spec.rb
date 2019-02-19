# frozen_string_literal: true

require 'sphinx_helper'

feature 'User can search for question', "
  In order to find needed question
  As a User
  I'd like to be able to search for the question
" do
  given!(:question_1) { create(:question, title: 'Question Title 1') }
  given!(:question_2) { create(:question, title: 'Question Title 2') }

  scenario 'User searches for the question', sphinx: true do
    visit questions_path
    ThinkingSphinx::Test.run do
      within '.search' do
        fill_in 'Search', with: 'Title 1'
        click_on 'Find'
      end

      expect(page).to have_content 'Question Title 1'
      expect(page).to have_content 'Search Results'
      expect(page).to_not have_content 'Question Title 2'
    end
  end
end
