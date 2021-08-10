# frozen_string_literal: true

RSpec.describe AccountSignUpController, type: :controller do
  let(:user) {}

  before do
    sign_in user if user
  end

  # This should return the minimal set of attributes required to create a valid
  # Account. As you add validations to Account, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { name: 'x' }
  end

  let(:invalid_attributes) do
    { tenant: 'missing-names', cname: '' }
  end

  context 'with access' do
    before do
      allow(Settings.multitenancy).to receive(:admin_only_tenant_creation).and_return(false)
    end

    describe "GET #new" do
      it "assigns a new account as @account" do
        get :new
        expect(response).to render_template("layouts/proprietor")
        expect(assigns(:account)).to be_a_new(Account)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        before do
          allow_any_instance_of(CreateAccount).to receive(:create_external_resources)
        end

        it "creates a new Account, but not a duplicate" do
          expect do
            post :create, params: { account: valid_attributes }
          end.to change(Account, :count).by(1)
          expect(assigns(:account).cname).to be_cname('x')
          expect(assigns(:account).errors).to be_empty

          expect do # now repeat the same action
            post :create, params: { account: valid_attributes }
          end.not_to change(Account, :count)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved account as @account" do
          post :create, params: { account: invalid_attributes }
          expect(assigns(:account)).to be_a_new(Account)
          expect(assigns(:account).tenant).not_to eq('missing-names')
          expect(assigns(:account).errors).not_to be_empty
          expect(assigns(:account).errors.messages).to match a_hash_including(:name, :"domain_names.cname")
        end

        it "re-renders the 'new' template" do
          post :create, params: { account: invalid_attributes }
          expect(response).to render_template("new")
        end
      end
    end
  end

  context 'without access' do
    before do
      allow(Settings.multitenancy).to receive(:admin_only_tenant_creation).and_return(true)
    end

    describe "GET #new" do
      it "redirects to sign in" do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "POST #create" do
      it "redirects to sign in" do
        post :create, params: { account: valid_attributes }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'as admin with restricted access' do
    let(:user) { FactoryBot.create(:admin) }

    before do
      allow(Settings.multitenancy).to receive(:admin_only_tenant_creation).and_return(true)
    end

    describe "GET #new" do
      it "assigns a new account as @account" do
        get :new
        expect(response).to render_template("layouts/proprietor")
        expect(assigns(:account)).to be_a_new(Account)
      end
    end

    describe "POST #create" do
      before do
        allow_any_instance_of(CreateAccount).to receive(:create_external_resources)
      end

      it "creates a new Account" do
        expect do
          post :create, params: { account: valid_attributes }
        end.to change(Account, :count).by(1)

        expect(assigns(:account).cname).to be_cname('x')
        expect(assigns(:account).errors).to be_empty
      end
    end
  end
end
