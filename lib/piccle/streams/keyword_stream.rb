require 'json'

# Browse photos by keyword.
class Piccle::Streams::KeywordStream
  def namespace
    "by-topic"
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
