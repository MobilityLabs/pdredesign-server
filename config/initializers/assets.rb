PdrServer::Application.config.angular_templates.ignore_prefix = %w(templates)
PdrServer::Application.config.assets.precompile += %w(pdr_client.css pdr_client.js mail.css)
PdrServer::Application.config.assets.precompile += %w(*.png *.jpeg *.jpg *.gif)
