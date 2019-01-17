# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Rating, type: :model do
  it { should have_many(:rating_changes) }
  it { should have_many(:users).through(:rating_changes) }
  it { should belong_to :ratable }
  it { should validate_presence_of :score }

  context 'Methods' do
    let(:user) { create(:user) }
    let(:author) { create(:user) }
    let(:question) { create(:question, user: author) }
    let(:rating) { create(:rating, ratable: question) }

    describe '#score_up' do
      it 'increases score value by 1' do
        rating.score_up(user)
        rating.reload

        expect(rating.score).to eq 1
      end

      it 'should throw exception if been updated by user, who is author of corresponding resource' do
        rating.score_up(author)

      rescue StandardError => e
        expect(e.message).to eq "User can't rate his resources"
      end
    end

    describe '#score_down' do
      it 'decreases score value by 1' do
        rating.score_down(user)
        rating.reload

        expect(rating.score).to eq(-1)
      end

      it 'should throw exception if been updated by user, who is author of corresponding resource' do
        rating.score_up(author)

      rescue StandardError => e
        expect(e.message).to eq "User can't rate his resources"
      end
    end

    describe '#rated_by?' do
      it 'returns user if he rated the resource' do
        rating.score_up(user)
        rated_user = rating.rated_by?(user)
        expect(rated_user).to eq user
      end

      it 'throws exception if user did not rate the resource' do
        rating.rated_by?(user)
      rescue ActiveRecord::RecordNotFound => e
        expect(e.message[0..27]).to eq "Couldn't find User with 'id'"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
