require "sqlite3"

namespace :db do
  desc "Create a database for photo data"
  task :initialise do
    # If a DB already exists, do nothing.
    if File.exist?(Piccle::PHOTO_DATABASE_FILENAME)
      puts "Database #{Piccle::PHOTO_DATABASE_FILENAME} already exists; exiting."
    else
      puts "Creating an empty DB..."
      db = SQLite3::Database.new(Piccle::PHOTO_DATABASE_FILENAME)
      puts "    ... and writing a schema to it..."
      db.execute <<-SQL
        CREATE TABLE photos(
          id INTEGER PRIMARY KEY,
          file_name text NOT NULL,
          path text NOT NULL,
          md5 varchar(128) NOT NULL,
          width integer NOT NULL,
          height integer NOT NULL,
          camera_name text,
          taken_at datetime,
          created_at datetime
        );
        SQL
      puts "    ... Done."
    end
  end

  desc "Drop the database"
  task :drop do
    File.delete("photo_data.db")
  end

  desc "Recreate the database"
  task recreate: [:drop, :initialise]
end
