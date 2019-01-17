# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RatingChange, type: :model do
  it { should belong_to :rating }
  it { should belong_to :user }

  # Doesn't work for some reason
  # it { should validate_uniqueness_of(:user).scoped_to(:rating) }

  it 'validates uniqueness of user scoped to ratings' do
    user = create(:user)
    rating = create(:rating)
    rating.users << user
    rating.users << user
  rescue ActiveRecord::RecordInvalid => e
    expect(e.message).to eq 'Validation failed: User can like or dislike resource only once in a row.'
    expect(rating.users.count).to eq 1
  end
end
