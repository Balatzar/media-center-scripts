require 'fileutils'
require 'thor'

class MediaScriptCLI < Thor
  desc "sanitize PATH", "Create a directory for every file in the specified directory and move the file in it"
  method_options path: :string
  def sanitize(path)
    Dir.children(path).each do |file|
        current_path = "#{path}/#{file}"
        next if FileTest.directory? current_path
        new_dir = "#{path}/#{File.basename(file, ".*")}"
        FileUtils.mkdir(new_dir)
        FileUtils.mv current_path, "#{new_dir}/#{file}"
    end
  end

  desc "rename PATH QUERY", "Renames files and directory by removing the specified query from their name if found"
  method_options path: :string, query: :string
  def rename(path, query)
    Dir.children(path).each do |file|
        next unless file.include? query
        current_path = "#{path}/#{file}"
        new_path = "#{path}/#{file.gsub(query, "")}"
        FileUtils.mv current_path, new_path
        pp "Renamed #{current_path} to #{new_path}"
    end
  end

  desc "test", "Start a rails console"
  method_options param: :string
  def test(param)
    pp param
  end
end

MediaScriptCLI.start(ARGV)
