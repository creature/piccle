require 'piccle'

namespace :photos do
  desc "List out photo attributes"
  task :list do
    Dir.glob("images/**").each do |filename|
      puts "#{filename}:"
      photo = Piccle::Photo.new(filename)

      puts "    Width: #{photo.width}"
      puts "    Height: #{photo.height}"
      puts "    Camera: #{photo.model}"
      puts "    Taken at: #{photo.taken_at}"
      puts "    MD5: #{photo.md5}"
      puts "--------------------------"
    end
  end

  desc "Update the database with photo info"
  task :update_db do
    Dir.glob("images/**").each do |filename|
      print "Examining #{filename}..."
      photo = Piccle::Photo.new(filename)
      photo.save
      puts " Done."
    end
  end
end
