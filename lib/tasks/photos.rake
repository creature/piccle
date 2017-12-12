namespace :photos do
  desc "List out photo attributes"
  task :list do
    Dir.glob("images/**").each do |filename|
      puts filename
    end
  end
end
