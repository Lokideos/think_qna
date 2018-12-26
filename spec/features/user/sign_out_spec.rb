# frozen_string_literal: true

require 'rails_helper'

feature 'User can sign out', "
  In order to assure that nobody can enter the system with my account
  As a user
  I'd like to be able to log out of the system
" do

  given(:user) { create(:user) }

  scenario 'Authenticated user tries to log out of the system' do
    sign_in(user)
    visit root_path
    click_on 'Sign out'

    expect(page).to have_content 'Signed out successfully.'
  end

  scenario 'Nonauthenticated user tries to log out of the system' do
    visit root_path

    expect(page).to_not have_content 'Sign out'
  end
end
