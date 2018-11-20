require 'sequel'

DB = Piccle::Database.connect

# Represents a keyword/label/tag in the system. This is pulled out of the image XMP data.
class Piccle::Keyword < Sequel::Model
  many_to_many :photos
end
