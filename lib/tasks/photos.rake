require 'exifr/jpeg'
require 'digest'

namespace :photos do
  desc "List out photo attributes"
  task :list do
    Dir.glob("images/**").each do |filename|
      puts "#{filename}:"
      photo = EXIFR::JPEG.new(filename)

      puts "    Width: #{photo.width}"
      puts "    Height: #{photo.height}"
      puts "    Camera: #{photo.model}"
      puts "    Taken at: #{photo.date_time}"
      puts "    MD5: #{Digest::MD5.file(filename)}"
      puts "--------------------------"
    end
  end
end
