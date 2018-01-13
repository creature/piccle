# A simple Sinatra-based app designed to speed development.
# This is not the recommended way to use Piccle in production!

require 'piccle'
require 'sinatra'
require 'sinatra/reloader' if development?

set :public_dir, "#{File.dirname(__FILE__)}/../../assets"

get '/images/thumbnails/:file' do |file|
  # NOtE: MASSIVELY INSECURE
  send_file "#{File.dirname(__FILE__)}/../../generated/images/thumbnails/#{file}"
end

get '/' do
  Piccle::TemplateHelpers.render("index", photos: Piccle::Photo.reverse_order(:taken_at).all, site_metadata: {}, relative_path: "/")
end

