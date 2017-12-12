require 'piccle'

namespace :photos do
  desc "List out photo attributes"
  task :list do
    Dir.glob("images/**").each do |filename|
      puts "#{filename}:"
      photo = Piccle::Photo.new(filename)

      puts "    Width: #{photo.width}"
      puts "    Height: #{photo.height}"
      # puts "    Camera: #{photo.model}"
      # puts "    Taken at: #{photo.date_time}"
      puts "    MD5: #{photo.md5}"
      puts "--------------------------"
    end
  end
end
