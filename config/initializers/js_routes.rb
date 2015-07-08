JsRoutes.setup do |config|
  config.default_url_options = { format: "json" }
  config.exclude = [ /admin/, /devise/ ]
end
