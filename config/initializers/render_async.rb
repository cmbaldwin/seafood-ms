RenderAsync.configure do |config|
  config.jquery = true # This will render jQuery code, and skip Vanilla JS code. The default value is false.
  config.turbolinks = true # Enable this option if you are using Turbolinks 5+. The default value is false.
  # config.replace_container = false # Set to false if you want to keep the placeholder div element from render_async. The default value is true.
  # config.nonces = true # Set to true if you want render_async's javascript_tag to always receive nonce: true. The default value is false.
end