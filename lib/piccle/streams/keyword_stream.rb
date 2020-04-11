require 'json'

# Browse photos by keyword.
class Piccle::Streams::KeywordStream
  def namespace
    "by-topic"
  end

  # Standard method called by the parser object. Returns a hash that contains the data to merge for the given photo.
  def data_for(photo)
    result = { namespace => {
               :friendly_name => "By Topic"
             }}
    photo.keywords.each do |kw|
      result[namespace][kw.name] = { photos: [photo.md5] }
    end
    result
  end

  def generate_json(root_path)

  end

  def generate_html(root_path)

  end

  def html_path_for(keyword)
    url_safe_keyword = keyword.downcase.gsub(/[_ ]/, "-")
    "#{namespace}/#{url_safe_keyword}.html"
  end

  protected

  def keywords
    @keywords ||= Piccle::Keyword.all
  end
end
