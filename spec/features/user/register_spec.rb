# frozen_string_literal: true

require 'rails_helper'

feature 'User can register in the system', "
  In order work with the system
  As a user
  I'd like to be able to register in the system
" do

  background { visit new_user_registration_path }

  scenario 'User tries to register in the system using correct credentials' do
    fill_in 'Email', with: 'goblin@slayer.com'
    fill_in 'Password', with: 'where_are_the_goblins?'
    fill_in 'Password confirmation', with: 'where_are_the_goblins?'
    click_on 'Sign up'

    expect(page).to have_content 'A message with a confirmation link has been sent to your email address.'
    expect(page).to_not have_link 'Sign out'

    open_email('goblin@slayer.com')
    current_email.click_link 'Confirm my account'
    expect(page).to have_content 'Your email address has been successfully confirmed.'
    expect(page).to_not have_link 'Sign out'

    fill_in 'Email', with: 'goblin@slayer.com'
    fill_in 'Password', with: 'where_are_the_goblins?'
    click_on 'Log in'

    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_link 'Sign out'
  end

  scenario 'User tries to register in the system with incorrect credentials' do
    click_on 'Sign up'

    expect(page).to have_content "Email can't be blank"
  end
end
