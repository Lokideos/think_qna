# frozen_string_literal: true

require 'sphinx_helper'

feature 'User can search for answer', "
  In order to find needed answer
  As a User
  I'd like to be able to search for the answer
" do
  given!(:answer_1) { create(:answer, body: 'Answer Body 1') }
  given!(:answer_2) { create(:answer, body: 'Answer Body 2') }

  scenario 'User searches for the answer', sphinx: true do
    visit questions_path
    ThinkingSphinx::Test.run do
      within '.search' do
        fill_in 'Search', with: 'Body 1'
        select 'Answer', from: 'Search Type'
        click_on 'Find'
      end

      expect(page).to have_content 'Answer Body 1'
      expect(page).to have_content 'Search Results'
      expect(page).to_not have_content 'Answer Body 2'
    end
  end
end
