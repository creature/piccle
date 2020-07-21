# frozen_string_literal: true

# Streams are a self-contained way of faceting data for a photo.

class Piccle::Streams::BaseStream
  #
  def namespace
    "by-foo"
  end

  # Returns a hash that contains data to merge for the given photo.
  def data_for(photo)
    {}
  end

  # def metadata_for(photo)
  #   [{}]
  # end

  # Reorder the data within this stream.
  #
  # The parser calls #order on every stream once it's loaded all the photos. You can reorder your data as you see fit.
  # For instance, most general streams will want to order their subphotos by date - but if you're a keyword stream,
  # you might also put the most popular keywords first.
  #
  # The default implementation organises facets with the most popular items first, and reorders the photos by date.
  #
  # Each stream is expected to only meddle within its own namespace, but this is not enforced.
  def order(data)
    if data.key?(namespace)
      data[namespace] = data[namespace].sort_by(&length_sort_proc(data)).reverse.to_h
      data[namespace].each do |k, v|
        data[namespace][k][:photos] = data[namespace][k][:photos].sort_by(&date_sort_proc(data)).reverse if k.is_a?(String)
      end
    end

    data
  end

  protected

  # A sort proc designed for hashes. Sorts all string keys in order of how many photos they contain.
  def length_sort_proc(data)
    Proc.new { |k, v| k.is_a?(String) ? data.dig(namespace, k, :photos)&.length : 0 }
  end

  # A date sort designed for arrays. Sorts all photo hashes in order of the date they were taken.
  def date_sort_proc(data)
    Proc.new { |hash| data.dig(:photos, hash, :taken_at) || Time.new(1970, 1, 1) }
  end
end
