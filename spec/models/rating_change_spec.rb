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

    expect { rating.users << user }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
