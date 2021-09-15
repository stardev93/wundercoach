module Embedded
  # provides context for a widget based on an event
  # make the replacings for javascript event lists
  class CoachDecorator < Draper::Decorator
    delegate_all
    attr_accessor :adpartner_id

    def context
      {
        'id' => object.id,
        'lastname' => object&.decorate&.lastname,
        'firstname' => object&.decorate&.firstname,
        'tel' => object&.decorate&.tel,
        'gender' => object&.decorate&.gender,
        'gender_indirect' => object&.decorate&.gender_indirect,
        'email' => object&.decorate&.email,
        'price_unit' => object&.price_unit,
        'active' => object&.decorate&.active,
        'title' => object&.decorate&.title,
        'image_file_name' => object&.image_file_name,
        'image_content_type' => object&.image_content_type,
        'image_file_size' => object&.image_file_size,
        'image_updated_at' => object&.image_updated_at,
        'price_cents' => object&.decorate&.price_cents,
        'homepage_url' => object&.homepage_url,
        'homepage_url_target_blank' => object&.homepage_url_target_blank,
        'label' => object&.label,
        'description' => object&.description,
        'created_at' => object&.created_at,
        'updated_at' => object&.updated_at

      }
    end
  end
end
