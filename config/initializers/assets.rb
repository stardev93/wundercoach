# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( application.js dashboard/dashboard.js dashboard.css signup/default.css backend signup/embedded.scss)
Rails.application.config.assets.precompile += %w( icheck/square/blue.png )
Rails.application.config.assets.precompile += %w( icheck/square/blue@2x.png )

# precompile stylesheets for wicked_pdf
Rails.application.config.assets.precompile += %w(invoice_pdf.css accountinvoice_pdf.css participantlist_pdf.css)
Rails.application.config.assets.paths << Rails.root.join("private")
Rails.application.config.assets.paths << Rails.root.join("private", "system")
Rails.application.config.assets.paths << Rails.root.join("public", "system")