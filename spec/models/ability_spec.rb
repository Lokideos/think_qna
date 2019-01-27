# frozen_string_literal: true

require 'rails_helper'

describe Ability do
  subject(:ability) { Ability.new(user) }

  context 'as a guest user' do
    let(:user) { nil }

    it { should be_able_to :read, Question }
    it { should be_able_to :read, Answer }
    it { should be_able_to :read, Comment }

    it { should_not be_able_to :manage, :all }
  end

  context 'as admin user' do
    let(:user) { create(:user, admin: true) }

    it { should be_able_to :manage, :all }
  end
end
