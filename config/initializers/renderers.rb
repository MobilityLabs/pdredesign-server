PDFKit.configure do |config|
  config.default_options = {
    page_size: 'Legal',
    print_media_type: false
  }
  config.verbose = false
end

ActionController::Renderers.add :pdf do |filename, options|
  kit = PDFKit.new(render_to_string(options), disable_javascript: true )
  send_data(
    kit.to_pdf,
    filename: "#{filename.to_s}.pdf",
    type: "application/pdf",
    disposition: 'attachment'
  )
end

ActionController::Renderers.add :csv do |filename, options|
  send_data render_to_string(options), type: Mime[:csv],
    disposition: "attachment; filename=#{filename.to_s}.csv"
end
