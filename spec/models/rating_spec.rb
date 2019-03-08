# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Rating, type: :model do
  it { should have_many(:rating_changes) }
  it { should have_many(:users).through(:rating_changes) }
  it { should belong_to(:ratable).touch(true) }
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
        expect { rating.score_up(author) }.to raise_error(StandardError)
      end

      it 'changes status to liked' do
        rating.score_up(user)
        expect(rating.rating_changes.where(rating_id: rating, user_id: user).first.status).to eq 'liked'
      end
    end

    describe '#score_down' do
      it 'decreases score value by 1' do
        rating.score_down(user)
        rating.reload

        expect(rating.score).to eq(-1)
      end

      it 'should throw exception if been updated by user, who is author of corresponding resource' do
        expect { rating.score_up(author) }.to raise_error(StandardError)
      end

      it 'changes status to unliked' do
        rating.score_down(user)
        expect(rating.rating_changes.where(rating_id: rating, user_id: user).first.status).to eq 'disliked'
      end
    end

    describe '#rated?' do
      it 'returns true if ratable object exists' do
        rating.score_up(user)
        expect(rating).to be_rated(user)
      end

      it 'returns false if ratable object does not exist' do
        expect(rating).to_not be_rated(user)
      end
    end

    describe '#score_delete' do
      it 'decreases score value by 1 if it was previously liked' do
        rating.score_up(user)
        score = rating.score
        rating.score_delete(user)
        rating.reload

        expect(rating.score).to eq score - 1
      end

      it 'increases score value by 1 if it was previously disliked' do
        rating.score_down(user)
        score = rating.score
        rating.score_delete(user)
        rating.reload

        expect(rating.score).to eq score + 1
      end

      it 'should throw exception if been updated by user, who is author of corresponding resource' do
        expect { rating.score_delete(author) }.to raise_error(StandardError)
      end

      it 'deletes associated rating change' do
        rating.score_up(user)
        rating.score_delete(user)
        expect(rating.rating_changes.where(rating_id: rating, user_id: user).first).to be_nil
      end
    end

    describe '#not_been_rated_this_way?' do
      it 'returns true if there is no records with given user and value' do
        expect(rating).to be_not_been_rated_this_way(user, 'liked')
      end

      it 'does not return true if there is a record with given user and value' do
        rating.score_up(user)
        expect(rating).to_not be_not_been_rated_this_way(user, 'liked')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
