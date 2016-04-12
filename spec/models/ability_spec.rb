require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject { described_class.new(user) }

  describe 'an anonymous user' do
    let(:user) { nil }
    it { is_expected.not_to be_able_to(:manage, :all) }
  end

  describe 'an ordinary user' do
    let(:user) { FactoryGirl.create(:user) }
    it { is_expected.not_to be_able_to(:manage, :all) }
  end

  describe 'an administrative user' do
    let(:user) { FactoryGirl.create(:admin) }
    it { is_expected.not_to be_able_to(:manage, :all) }
    it { is_expected.not_to be_able_to(:manage, Account) }
    it { is_expected.to be_able_to(:manage, Site) }
  end

  describe 'a superadmin user' do
    let(:user) { FactoryGirl.create(:superadmin) }
    it { is_expected.to be_able_to(:manage, :all) }
  end
end
