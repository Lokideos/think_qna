# frozen_string_literal: true

require 'rails_helper'

feature 'User can cancel his subscription to the question', "
  In order to stop tracking not interesting questions
  As a User, subscribed to this question
  I'd like to be able to cancel my subscription
" do
  given(:user) { create(:user) }
  given(:question) { create(:question, title: 'Unsubscribed Question') }

  context 'Authenticated user' do
    before { sign_in(user) }

    before do
      user.subscribe(question)
      visit question_path(question)
    end

    scenario 'cancels his subscription', js: true do
      within '.question' do
        click_on 'Cancel Subscription'
      end

      expect(page).to_not have_link 'Cancel Subscription'
      expect(page).to have_link 'Subscribe'
      expect(page).to have_content 'You have cancel your subscription to Unsubscribed Question'
    end

    scenario 'tries to cancel his subscription, when there is no active subscription to this question'
  end

  scenario 'Unauthenticated user tries to cancel subscription'
end
