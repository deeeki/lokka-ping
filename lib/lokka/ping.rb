module Lokka
  module Ping
    def self.registered(app)
      app.get '/admin/plugins/ping' do
        haml :"plugin/lokka-ping/views/index", :layout => :"admin/layout"
      end

      app.put '/admin/plugins/ping' do
        Option.ping_servers = params['ping_servers']
        Option.site_url = params['site_url']
        flash[:notice] = 'Updated.'
        redirect '/admin/plugins/ping'
      end
    end
  end
end

class Entry
  after :create do
    servers = Option.ping_servers.split("\r\n")
    servers.each do |s|
      client = XMLRPC::Client.new2(s)
      begin
        res = client.call("weblogUpdates.ping", Site.first.title, Option.site_url)
      rescue Exception => e
        res = {"message" => "#{e.class}: #{e.message}", "flerror" => nil}
      end
      puts "Pingged: #{s}"
      puts res["message"]
      puts res["flerror"]
    end
  end
end

require 'xmlrpc/client'
module XMLRPC::ParseContentType
  def parse_content_type(str)
    a, *b = str.split(";")
    if a == "application/xml" || a == "text/html"
      a = "text/xml"
    end
    return a.strip.downcase, *b
  end
end
