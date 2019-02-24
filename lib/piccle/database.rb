require 'sequel'

# A place to initialise the database. This is probably temporary, and will be moved to
# a better home once I find one.
class Piccle::Database
  PHOTO_DATABASE_FILENAME = "photo_data.db"
  PHOTO_TEST_DATABASE_FILENAME = "photo_data_test.db"


  def self.connect
    if ENV.fetch('PICCLE_ENV', 'production') == "production"
      Sequel.connect("sqlite://#{PHOTO_DATABASE_FILENAME}")
    else
      Sequel.connect("sqlite://#{PHOTO_TEST_DATABASE_FILENAME}")
    end
  end
end
