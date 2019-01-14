# frozen_string_literal: true

require 'rails_helper'

feature 'User create a reward for best answer during question creation', "
  In order to reward person, who gives best answer to my question
  As Author of question
  I'd like to be able to create reward for best answer to my question
" do
  given(:user) { create(:user) }

  scenario 'Author of the question during question creation creates the reward for best answer' do
    sign_in(user)
    visit new_question_path

    within '.question-info' do
      fill_in 'Title', with: 'New Question Title'
      fill_in 'Body', with: 'New Question Body'
    end

    within '.best-answer-reward' do
      fill_in 'Title', with: 'New Reward Title'
      attach_file 'Image', "#{Rails.root}/spec/fixtures/files/image.jpg"
    end

    click_on 'Ask'

    expect(page).to have_content 'New Reward Title'
    expect(page).to have_css("img[src^='https://#{ENV['S3_TEST_BUCKET']}']")
  end
end
