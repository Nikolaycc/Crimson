require "http/server"
require "html_builder"
require "./crimson_endpoint.cr"

app = Crimson::Endpoint.new

app.get "/home", do |res, req, params|
  res.content_type = "text/html"
  res.print "Hello world, got #{req.path}!"
end

app.get "/", do |res, req, params|
  res.content_type = "text/html"
  res.print "FUCKING MF!! :*"
end

app.get "/hello/:name", do |res, req, params|
  res.content_type = "text/html"
  res.print "Hello, #{params["name"]?}"
end

app.run(8080)
