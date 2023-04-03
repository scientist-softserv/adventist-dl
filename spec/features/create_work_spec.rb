# frozen_string_literal: true

RSpec.describe 'Creating a new Work', :clean do
  let(:user) do
    u = create(:user)
    u.add_role(:depositor)
    u
  end

  before do
    AdminSet.find_or_create_default_admin_set_id
    login_as user, scope: :user
  end

  xit 'creates the work' do
    visit '/'
    click_link "Contribute"
    expect(page).to have_button "Create work"
  end
end
