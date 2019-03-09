# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reward, type: :model do
  it { should validate_presence_of :title }

  it { should belong_to(:question).touch(true) }
  it { should belong_to(:user).optional }

  it 'has one attached image' do
    expect(Reward.new.image).to be_an_instance_of(ActiveStorage::Attached::One)
  end
end
