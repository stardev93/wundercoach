require "rails_helper"

RSpec.describe EventsController, type: :controller do
	let(:locale) { 'de' }
	let(:user) { create(:user) }

	before {
		request.host = "#{user.account.subdomain}.lvh.me"
		login_user(user)
	}

	describe '#index' do
		context 'with default events' do
			let!(:events) { create_list(:event, 3, account_id: user.account_id) }

			it "returns events" do
				get :index, locale: locale

				expect(assigns(:events)).not_to be_empty
			end
		end

		context "with 'Eventtemplate' events" do
			let!(:events) { create_list(:event, 3, :event_template, account_id: user.account_id) }

			it "doesn't return events" do
				get :index, locale: locale

				expect(assigns(:events)).to be_empty
			end
		end

		context "when searching" do
			context "by coach" do
				let(:coach) { create(:coach, account_id: user.account_id) }
				let!(:events) { create_list(:event, 3, account_id: user.account_id, coaches: [coach]) }

				it "returns events" do
					get :index, locale: locale, q: { coaches_id_eq: coach.id }

					expect(assigns(:events).length).to eq(3)
				end
			end

			context "by tags" do
				let(:tag) { create(:product_tag, account_id: user.account_id) }
				let!(:events) { create_list(:event, 3, account_id: user.account_id, product_tags: [tag]) }

				it "returns events" do
					get :index, locale: locale, q: { product_tags_id_eq: tag.id }

					expect(assigns(:events).length).to eq(3)
				end
			end

			context "by online status" do
				let(:online_status) { create(:onlinestatus) }
				let!(:events) { create_list(:event, 3, account_id: user.account_id, onlinestatus: online_status) }

				it "returns events" do
					get :index, locale: locale, q: { onlinestatus_id_eq: online_status.id }

					expect(assigns(:events).length).to eq(3)
				end
			end

			context "by event type" do
				let(:event_type) { create(:eventtype) }
				let!(:events) { create_list(:event, 3, account_id: user.account_id, eventtype: event_type) }

				it "returns events" do
					get :index, locale: locale, q: { eventtype_id_eq: event_type.id }

					expect(assigns(:events).length).to eq(3)
				end
			end

			context "by type" do
				let!(:events) { create_list(:event, 3, account_id: user.account_id) }

				it "returns events" do
					get :index, locale: locale, q: { type_eq: 'StandardEvent' }

					expect(assigns(:events).length).to eq(3)
				end
			end

			context "by search term" do
				let!(:event) { create(:event, name: 'new event', account_id: user.account_id) }
				let(:search_query) { { name_or_shortdescription_or_longdescription_or_location_or_zip_or_street_or_city_cont: 'new' } }

					it "returns events" do
						get :index, locale: locale, q: search_query

						expect(assigns(:events).length).to eq(1)
					end
			end

			context "by start date" do
				let!(:events) { create_list(:event, 3, start_date: Time.now, account_id: user.account_id) }
				let(:search_query) {
					{ start_date_gteq: Time.now.strftime('%Y-%m-%d') }
				}

				it "returns events with start date equal to or greater than today" do
					get :index, locale: locale, q: search_query

					expect(assigns(:events).length).to eq(3)
				end
			end

			context "by end date" do
				let!(:events) { create_list(:event, 3, start_date: Time.now, account_id: user.account_id) }
				let(:search_query) {
					{ start_date_lteq: (Time.now + 1.day).strftime('%Y-%m-%d') }
				}

				it "returns events with start date equal to or lower than today" do
					get :index, locale: locale, q: search_query

					expect(assigns(:events).length).to eq(3)
				end
			end
		end
	end

	describe "#new" do
		before {
			get :new, locale: locale
		}

		it "builds the @event with default values" do
			expect(response).to have_http_status(:ok)
			expect(assigns(:event)).to be_a_new(StandardEvent)
		end
	end

	describe "#create" do
		context "with valid attributes" do
			before {
				post :create, locale: locale, event: attributes_for(:event)
			}

			it "creates a new event" do
				expect(Event.count).to eq(1)
			end

			it "redirects to the new event" do
				expect(response).to redirect_to(Event.last)
			end
			
			it 'sets flash message' do
        expect(flash[:notice]).to eq(I18n.t(:event_was_successfully_created))
      end
		end

		context "with invalid attributes" do
			before {
				post :create, locale: locale, event: attributes_for(:invalid_event)
			}

			it "doesn't save the new event" do
				expect(Event.count).to eq(0)
			end

			it "renders the new action" do
				expect(response).to render_template(:new)
    	end
		end
	end

	describe "#edit" do
		let!(:event) { create(:event, account_id: user.account_id) }

		before {
			get :edit, locale: locale, id: event
		}

		it "sets @event" do
			expect(assigns(:event)).to_not be_nil
		end

		it 'renders edit template' do
			expect(response).to render_template(:edit)
		end
	end

	describe "#update" do
		let!(:event) { create(:event, account_id: user.account_id) }

		context "with valid attributes" do
			before {
				put :update, locale: locale, id: event, event: { name: 'Event' }
			}

			it "changes @events's attributes" do
				event.reload
				expect(event.name).to eq('Event')
			end

			it 'redirects to event url' do
				expect(response).to redirect_to(event_url(event))
			end

			it 'sets flash message' do
        expect(flash[:notice]).to eq(I18n.t(:event_was_successfully_updated))
      end
		end

		context "with invalid attributes" do
			before {
				put :update, locale: locale, id: event, event: { name: '' }
			}

			it "doesn't change @event's attributes" do
				event.reload
				expect(event.name).not_to be_empty
			end

			it 'renders edit template' do
        expect(response).to render_template(:edit)
      end
		end
	end

	describe "#destroy" do
		let!(:event) { create(:event, account_id: user.account_id) }

		before {
			delete :destroy, locale: locale, id: event
		}

		it "deletes the event" do
			expect(Event.count).to eq(0)
		end

		it "redirects to events#index" do
			expect(response).to redirect_to(events_url)
		end

		it 'sets flash message' do
			expect(flash[:notice]).to eq(I18n.t(:event_was_successfully_deleted))
		end
	end

	describe "#new_individual" do
		before {
			get :new_individual, locale: locale
		}

		it "builds the individual event object" do
			expect(assigns(:event)).to be_a_new(IndividualEvent)
		end

		it "builds with max participants equal to 1" do
			expect(assigns(:event).maxparticipants).to eq(1)
		end

		it "builds with max additional participants equal to 0" do
			expect(assigns(:event).max_additional_participants).to eq(0)
		end

		it "assigns a payment method to the event" do
			expect(assigns(:event).paymentmethods).not_to be_empty
		end

		it 'renders new template' do
      expect(response).to render_template(:new)
    end
	end

	describe "#new_free" do
    before {
      get :new_free, locale: locale
    }

    it "builds the free event object" do
      expect(assigns(:event)).to be_a_new(FreeEvent)
		end

		it "contains start date" do
			expect(assigns(:event).start_date).to_not be_nil
		end

		it "contains end date" do
			expect(assigns(:event).end_date).to_not be_nil
		end

		it "contains latest signup date" do
			expect(assigns(:event).latest_signup_date).to_not be_nil
		end

		it "contains reservation expiry" do
			expect(assigns(:event).reservation_expiry).to_not be_nil
		end

		it "contains max participants" do
			expect(assigns(:event).maxparticipants).to_not be_nil
		end

		it "contains max additional participants" do
			expect(assigns(:event).max_additional_participants).to_not be_nil
		end

    it 'renders new template' do
      expect(response).to render_template(:new)
		end
	end

	describe "#new_online" do
		before {
			get :new_online, locale: locale
		}

		it "builds the online event object" do
			expect(assigns(:event)).to be_a_new(OnlineEvent)
		end

		it "contains start date" do
			expect(assigns(:event).start_date).to_not be_nil
		end

		it "contains end date" do
			expect(assigns(:event).end_date).to_not be_nil
		end

		it "contains latest signup date" do
			expect(assigns(:event).latest_signup_date).to_not be_nil
		end

		it "contains reservation expiry" do
			expect(assigns(:event).reservation_expiry).to_not be_nil
		end

		it "contains max participants" do
			expect(assigns(:event).maxparticipants).to_not be_nil
		end

		it "contains max additional participants" do
			expect(assigns(:event).max_additional_participants).to_not be_nil
		end

    it 'renders new template' do
      expect(response).to render_template(:new)
		end
	end

	describe "#new_bundle" do
    before {
      get :new_bundle, locale: locale
    }

    it "builds the bundle event object" do
      expect(assigns(:event)).to be_a_new(BundleEvent)
    end

		it "contains max participants" do
			expect(assigns(:event).maxparticipants).to_not be_nil
		end

		it "contains max additional participants" do
			expect(assigns(:event).max_additional_participants).to_not be_nil
		end

    it 'renders new template' do
      expect(response).to render_template(:new)
    end
  end
end
