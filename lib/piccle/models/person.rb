require 'sequel'

# Represents a real-life person. Uses the IPTC4 "PersonInImage" field in XMP data.
class Piccle::Person < Sequel::Model
  many_to_many :photos
end
