# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can create question', "
  In order to get an answer from the community
  As an authenticated user
  I'd like to be able to ask the question
" do

  given(:user) { create(:user) }

  describe 'Authenticated user' do
    background do
      sign_in(user)

      visit questions_path
      click_on 'Ask question'
    end

    scenario 'asks a question' do
      within '.question-info' do
        fill_in 'Title', with: 'Test question'
        fill_in 'Body', with: 'text text text'
      end

      click_on 'Ask'

      expect(page).to have_content 'Your Question has been successfully created.'
      expect(page).to have_content 'Test question'
      expect(page).to have_content 'text text text'
    end

    scenario 'asks a question with errors' do
      click_on 'Ask'

      expect(page).to have_content "Title can't be blank"
    end

    scenario 'asks a question with attached file' do
      within '.question-info' do
        fill_in 'Title', with: 'Test question'
        fill_in 'Body', with: 'text text text'
      end

      attach_file 'File', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Ask'

      expect(page).to have_link 'rails_helper.rb'
      expect(page).to have_link 'spec_helper.rb'
    end

    scenario 'is subscribed to question after question creation' do
      within '.question-info' do
        fill_in 'Title', with: 'Test question'
        fill_in 'Body', with: 'text text text'
      end

      click_on 'Ask'

      expect(page).to_not have_link 'Subscribe'
    end
  end

  scenario 'Unauthenticated user tries to ask a question' do
    visit questions_path
    click_on 'Ask question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  context 'multiple sessions' do
    scenario "on all questions' page user sees newly created by other user question", js: true do
      Capybara.using_session('user') do
        sign_in(user)
        visit questions_path
      end

      Capybara.using_session('guest') do
        visit questions_path
      end

      Capybara.using_session('user') do
        click_on 'Ask question'

        within '.question-info' do
          fill_in 'Title', with: 'Test question'
          fill_in 'Body', with: 'text text text'
        end

        click_on 'Ask'

        within '.question-info' do
          expect(page).to have_content 'Test question'
          expect(page).to have_content 'text text text'
        end
      end

      Capybara.using_session('guest') do
        expect(page).to have_content 'Test question'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
