class PropagationForm < Reform::Form
  feature Coercion
  property :id
  property :copy_name, virtual: true, type: Types::Form::Bool, default: false
  property :copy_shortdescription, virtual: true, type: Types::Form::Bool, default: false
  property :copy_longdescription, virtual: true, type: Types::Form::Bool, default: false
  property :copy_bottom_text, virtual: true, type: Types::Form::Bool, default: false
  property :copy_full_price_cents, virtual: true, type: Types::Form::Bool, default: false
  # property :copy_early_signup_pricing, virtual: true, type: Types::Form::Bool, default: false
  property :copy_price_early_signup_cents, virtual: true, type: Types::Form::Bool, default: false

  # validation do
  #  required(:eventtemplate_id).filled
  # end
end
