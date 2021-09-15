FactoryGirl.define do
  factory :product_tag, class: 'Product::Tag' do
    name { Faker::Name.name }
  end
end
