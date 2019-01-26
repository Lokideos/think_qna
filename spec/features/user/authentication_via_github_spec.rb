# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can authenticate via github', "
  In order to simplify access to web application
  As a User
  I'd like to be able to authenticate through github
" do

  scenario 'User authenticates via his github account' do
    visit new_user_session_path

    github_mock_auth_hash
    click_on 'Sign in with GitHub'

    expect(page).to have_content 'Successfully authenticated from Github account.'
    expect(page).to have_link 'Sign out'
  end

  context 'oauth provider does not provide email' do
    scenario 'Existing User tries to authenticate via github account with no email provider' do
      create(:user, email: 'existing_email@email.com')
      visit new_user_session_path

      github_no_email_auth_hash
      click_on 'Sign in with GitHub'

      expect(page).to have_content 'No email was provided by GitHub. Please provide your email'
      expect(page).to_not have_link 'Sign out'

      fill_in 'Email', with: 'existing_email@email.com'
      click_on 'Confirm Email'

      expect(page).to have_content 'You account has been link to your Github account.'
      expect(page).to_not have_link 'Sign out'

      click_on 'Sign in with GitHub'
      expect(page).to have_content 'Successfully authenticated from Github account.'
      expect(page).to have_link 'Sign out'
    end

    scenario 'Non-existing User tries to authenticate via github account' do
      visit new_user_session_path

      github_no_email_auth_hash
      click_on 'Sign in with GitHub'

      expect(page).to have_content 'No email was provided by GitHub. Please provide your email'
      expect(page).to_not have_link 'Sign out'

      fill_in 'Email', with: 'goodemail@test.com'
      click_on 'Confirm Email'

      open_email('goodemail@test.com')
      current_email.click_link 'Confirm my account'

      expect(page).to have_content 'Your email address has been successfully confirmed.'
      expect(page).to_not have_link 'Sign out'

      click_on 'Sign in with GitHub'
      expect(page).to have_content 'Successfully authenticated from Github account.'
      expect(page).to have_link 'Sign out'
    end
  end

  scenario 'User tries to authenticate via his github account with invalid account data' do
    invalid_mock_auth_hash
    visit new_user_session_path

    click_on 'Sign in with GitHub'
    expect(page).to have_content 'Could not authenticate you from GitHub because "Invalid credentials".'
    expect(page).to_not have_link 'Sign out'
  end
end
# rubocop:enable Metrics/BlockLength
