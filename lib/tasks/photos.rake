require 'piccle'

namespace :photos do
  desc "List out photo attributes"
  task :list do
    Piccle::Photo.all.each do |photo|
      puts "#{photo.original_photo_path}:"
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
      photo = Piccle::Photo.from_file(filename)
      if photo.modified?
        print " updating..."
        photo.update_from_file
        puts " done."
      elsif photo.freshly_created?
        puts " created."
      else
        puts " done."
      end
    end
  end
end
