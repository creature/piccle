# A simple Sinatra-based app designed to speed development.
# This is not the recommended way to use Piccle in production!

require 'piccle'
require 'sinatra'
require 'sinatra/reloader' if development?

set :public_dir, "#{File.dirname(__FILE__)}/../../assets"

get '/images/:location/:file' do |location, file|
  # NOTE: MASSIVELY INSECURE
  send_file "#{File.dirname(__FILE__)}/../../generated/images/#{location}/#{file}"
end

get '/' do
  Piccle::TemplateHelpers.render("index", photos: Piccle::Photo.reverse_order(:taken_at).all, site_metadata: site_metadata, relative_path: "/")
end

get '/photos/:hash' do |hash|
  hash.sub!(/\.html$/, "")
  photo = Piccle::Photo.where(md5: hash).first
  Piccle::TemplateHelpers.render("show", photo: photo, site_metadata: site_metadata, relative_path: "/")
end

# TODO: pull this out to work via some kind of extension in the date-stream itself.
get '/by-date/:year' do |year|
  stream = Piccle::Streams::DateStream.new
  stream.html_for_year(year)
end

get '/by-topic/:keyword' do |keyword|
  stream = Piccle::Streams::KeywordStream.new
  stream.html_for_keyword(keyword)
end

def site_metadata
  Piccle::TemplateHelpers.site_metadata
end
