# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
feature 'User can see his rewards', "
  In order to know my contribution to community
  As a User
  I'd like to be able to check my rewards
" do
  given(:user) { create(:user) }
  given(:other_user) { create(:user) }
  given!(:reward) { create(:reward, user: user) }

  background do
    reward.image.attach(create_file_blob)
  end

  scenario 'User check his rewards' do
    sign_in(user)
    visit rewards_user_path(user)

    expect(page).to have_content reward.title
    expect(page).to have_content reward.question.title
    expect(page).to have_css("img[src^='https://#{ENV['S3_TEST_BUCKET']}']")
  end

  scenario "User tries to check other user's rewards" do
    sign_in(other_user)
    visit rewards_user_path(user)

    expect(page).to_not have_content reward.title
    expect(page).to_not have_css("img[src^='https://#{ENV['S3_TEST_BUCKET']}']")
    expect(page).to have_content "You can't check other user's rewards."
  end

  scenario 'Unauthenticated user tries to check user rewards' do
    visit rewards_user_path(user)

    expect(page).to_not have_content reward.title
    expect(page).to_not have_content reward.question.title
    expect(page).to_not have_css("img[src^='https://#{ENV['S3_TEST_BUCKET']}']")
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
# rubocop:enable Metrics/BlockLength
