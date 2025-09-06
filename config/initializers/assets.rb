Rails.application.config.assets.version = "1.0"

Rails.application.config.assets.precompile += %w[application.css application.js]

# config/initializers/assets.rb
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
