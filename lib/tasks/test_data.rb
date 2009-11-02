require 'monkey/string'

namespace :test do

  desc 'Create the test data mp3 files from their album.dat files.'
  task :data do
    Dir.glob('test/data/**/album.dat') do |album_dat_file_path|
      puts "auto-generating album files for #{album_dat_file_path}"
      album_folder = File.dirname(album_dat_file_path)
      album_file_list = File.readlines(album_dat_file_path).map {|l| l.chomp}
      album_file_list.each do |file_name|
        puts "auto-generating album file #{file_name}"
        file_name = file_name.chomp
        file_path = File.join(album_folder, file_name)
        create_fake_file file_path
      end
    end
  end

  def create_fake_file(file_path)
    if is_mp3_file?(file_path)
      create_mp3_fake_file file_path
    else
      create_empty_fake_file file_path
    end
  end

  def is_mp3_file?(file_path)
    file_path.ends_with?('.mp3')
  end

  def create_empty_fake_file(file_path)
    system %Q[touch "#{file_path}"]
  end

  def create_mp3_fake_file(file_path)
    system %Q[cp test/data/mp3_template_file "#{file_path}"]
  end

end
