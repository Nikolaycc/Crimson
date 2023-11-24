require "http/server"
require "radix"



module Crimson
  module Macros
  end
  
  class Endpoint
    #include Crimson::Macros

    alias Callb = (HTTP::Server::Response, HTTP::Request, Hash(String, String)) ->
    alias Route = Radix::Tree(Callb)
    
    getter routes : Route
    getter assign : Hash(String, Array(Route))
    getter scopes : Array(String) = [] of String
    
    def initialize()
      @routes = Route.new
      @assign = Hash(String, Array(Route)).new
    end

    private def set_route(path : String, cb : Callb)
      @routes.add path, cb
    end

    def run(port : Int32)
      server = HTTP::Server.new [
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
      ], do |context|
        r = @routes.find context.request.path
        if r.found?
          r.payload.call(context.response, context.request, r.params)
        else
          context.response.content_type = "text/html"
          context.response.status_code = 404
          context.response.print "Not Found"
        end
      end

      puts "Listening on http://127.0.0.1:#{port}"
      server.listen(port)
    end    

    {% for method in %w(get post delete patch put connect options trace head) %}
      def {{method.id}}(path : String, &cb : Callb)
        self.set_route @scopes.join + path, cb
      end
    {% end %}
  end

end
