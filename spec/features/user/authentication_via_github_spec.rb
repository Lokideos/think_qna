# frozen_string_literal: true

require 'rails_helper'

feature 'User can authenticate via github', "
  In order to simplify access to web application
  As a User
  I'd like to be able to authenticate through github
" do
  given(:user) { create(:user) }

  scenario 'User authenticates via his github account' do
    visit new_user_session_path

    mock_auth_hash
    click_on 'Sign in with GitHub'

    expect(page).to have_content 'Successfully authenticated from Github account.'
    expect(page).to have_link 'Sign out'
  end

  scenario 'User tries to authenticate via his github account with invalid account data' do
    invalid_mock_auth_hash
    visit new_user_session_path

    click_on 'Sign in with GitHub'
    expect(page).to have_content 'Could not authenticate you from GitHub because "Invalid credentials".'
    expect(page).to_not have_link 'Sign out'
  end
end
