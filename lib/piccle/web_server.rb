# A simple Sinatra-based app designed to speed development.
# This is not the recommended way to use Piccle in production!

require 'piccle'
require 'sinatra'
require 'sinatra/reloader' if development?

set :public_dir, "#{File.dirname(__FILE__)}/../../assets"

get '/images/:location/:file' do |location, file|
  # NOtE: MASSIVELY INSECURE
  send_file "#{File.dirname(__FILE__)}/../../generated/images/#{location}/#{file}"
end

get '/' do
  Piccle::TemplateHelpers.render("index", photos: Piccle::Photo.reverse_order(:taken_at).all, site_metadata: {}, relative_path: "/")
end

get '/photos/:hash' do |hash|
  hash.sub!(/\.html$/, "")
  photo = Piccle::Photo.where(md5: hash).first
  Piccle::TemplateHelpers.render("show", photo: photo, site_metadata: {}, relative_path: "/")
end

