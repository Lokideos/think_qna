# frozen_string_literal: true

require 'sphinx_helper'

feature 'User can search for comment', "
  In order to find needed comment
  As a User
  I'd like to be able to search for the comment
" do
  given!(:comment_1) { create(:comment, body: 'Comment Body 1') }
  given!(:comment_2) { create(:comment, body: 'Comment Body 2') }

  scenario 'User searches for the question', sphinx: true do
    visit questions_path
    ThinkingSphinx::Test.run do
      within '.search' do
        fill_in 'Search', with: 'Body 1'
        select 'Comment', from: 'Search Type'
        click_on 'Find'
      end

      expect(page).to have_content 'Comment Body 1'
      expect(page).to have_content 'Search Results'
      expect(page).to_not have_content 'Comment Body 2'
    end
  end
end
