require 'sequel'

# A place to initialise the database. This is probably temporary, and will be moved to
# a better home once I find one.
class Piccle::Database
  PHOTO_DATABASE_FILENAME = "photo_data.db"

  def self.connect
    Sequel.connect("sqlite://#{PHOTO_DATABASE_FILENAME}")
  end
end
