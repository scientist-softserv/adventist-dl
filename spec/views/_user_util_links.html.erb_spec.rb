# frozen_string_literal: true

# Turn off spec temporarily due to removing registerable
# ref https://github.com/scientist-softserv/adventist-dl/pull/493
RSpec.xdescribe '/_user_util_links.html.erb', type: :view do
  let(:user) { create(:user) }

  before do
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    render
  end

  it 'links to edit registration path' do
    expect(rendered).to have_link 'Change password', href: edit_user_registration_path
  end
end
