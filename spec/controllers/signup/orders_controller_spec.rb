require "rails_helper"

RSpec.describe Signup::OrdersController, type: :controller do
  let(:locale) { 'de' }
  let(:user) { create(:user) }

  before {
		request.host = "#{user.account.subdomain}.lvh.me"
	  login_user(user)
  }

  describe '#edit' do
    context "step 1" do
      let!(:order) { create(:order, account_id: user.account_id, user: user) }

      before {
				get :edit, locale: locale, id: order.id
      }

      it "has an order" do
        expect(assigns(:order)).not_to be_nil
      end

      it "builds the address object" do
        expect(assigns(:order).address).to be_a_new(Address)
      end

      it "builds the billing_address object" do
        expect(assigns(:order).billing_address).to be_a_new(Address)
      end
    end
  end

  describe '#update' do
    context "step 1 -> 2" do
      let!(:order) { create(:order, free: true, account_id: user.account_id, user: user) }

      context "with valid attributes" do
        order_params = {
          address_attributes: {
            company: 'Apple', lastname: 'Doe', firstname: 'John', gender: 'Male',
            email: 'john@gmail.com', street: '5th Avenue', zip: '12345', city: 'New York', country: 'USA'
          }
        }

        before {
          put :update, locale: locale, id: order.id, order: order_params
        }

        it "sets order" do
          expect(assigns(:order)).not_to be_nil
        end

        it "sets decorated order" do
          expect(assigns(:order)).to be_a(OrderDecorator)
        end

        it "sets product" do
          expect(assigns(:product)).not_to be_nil
        end

        it "redirects to next step" do
          expect(response).to redirect_to(confirm_signup_order_path(order))
        end
      end

      context "with invalid attributes" do
        order_params = {
          address_attributes: {
            gender: ''
          }
        }

        before {
          put :update, locale: locale, id: order.id, order: order_params
        }

        it "builds the address object" do
          expect(assigns(:order).address).to be_a_new(Address)
        end

        it "address the billing_address object" do
          expect(assigns(:order).billing_address).to be_a_new(Address)
        end

        it 'renders edit template' do
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe '#payment' do
    context "step 2" do
      let!(:order) { create(:order, account_id: user.account_id, user: user) }

      before {
				get :payment, locale: locale, id: order.id
      }

      it "has a product" do
        expect(assigns(:product)).not_to be_nil
      end

      it "sets decorated product" do
        expect(assigns(:product)).to be_a(EventDecorator)
      end
    end
  end

  describe '#set_payment' do
    context "step 2 -> 3" do
      let!(:order) { create(:order, account_id: user.account_id, user: user) }
      let(:payment_method) { create(:paymentmethod, :bank_transfer)}

      context "when the payment method is selected" do
        before {
	  			get :set_payment, locale: locale, id: order.id, order: { paymentmethod_id: payment_method.id }
        }

        it 'redirects to confirm url' do
				  expect(response).to redirect_to(confirm_signup_order_path(order))
			  end
      end

      context "when the payment method isn't selected" do
        before {
	  			get :set_payment, locale: locale, id: order.id
        }

        it "renders the payment action" do
				  expect(response).to render_template(:payment)
        end

        it 'sets flash message' do
          expect(flash[:notice]).to eq(I18n.t(:choose_a_paymentmethod))
        end

        it "sets decorated product" do
          expect(assigns(:order)).to be_a(OrderDecorator)
        end

        it "sets decorated product" do
          expect(assigns(:product)).to be_a(EventDecorator)
        end
      end
    end
  end

  describe '#confirm' do
    context "step 3" do
      let(:address) { create(:address, account_id: user.account_id) }
      let!(:order) { create(:order,
        :payment_chosen,
        account_id: user.account_id,
        user: user,
        address: address)
      }

      before {
        get :confirm, locale: locale, id: order.id
      }

      it "sets the address object" do
        expect(assigns(:address)).not_to be_nil
      end

      it "sets the product object" do
        expect(assigns(:product)).not_to be_nil
      end
    end
  end
end