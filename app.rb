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

  desc "subtitles PATH LANG", "Renames and associates .srt files to video files, and adds the specified lang at the end of the .srt files"
  method_options path: :string, lang: :string
  def subtitles(path, lang = nil)
    video_formats = %w[avi mkv mp4]
    subtitles_formats = %w[srt]
    episode_identification = /([s|S]\d{2}[e|E]\d{2})/ # https://rubular.com/r/tom3MtOhHl5c28
    FileUtils.cd path
    all_files = Dir.glob "*"
    file_pairs = {}
    all_files.each do |file|
      match = file.match episode_identification
      next unless match
      current_episode = file_pairs[match.captures.first.downcase] ||= {}
      if video_formats.any? { |format| file.include? format }
        current_episode[:video] = file
      elsif subtitles_formats.any? { |format| file.include? format }
        current_episode[:subtitles] = file
      else
        pp "Unrecognized file: #{file}"
      end
    end
    pp file_pairs
    file_pairs.each do |identification, files|
      if !files[:video] || !files[:subtitles]
        pp "Missing a file for #{identification}"
        next
      end
      video_file = files[:video]
      sub_file = files[:subtitles]
      video_name = File.basename video_file, ".*"
      sub_name = File.basename sub_file, ".*"
      sub_extension = File.extname sub_file
      pp "#{name}#{sub_extension}#{lang && ".#{lang}"}"
      FileUtils.mv sub_file, "#{name}#{sub_extension}#{lang && ".#{lang}"}"
    end
  end

  desc "setup_subtitles", "Create a test folder with files needed to test the subtitles command"
  def setup_subtitles
    path = "./test"
    FileUtils.remove_dir path rescue Errno::ENOENT
    FileUtils.mkdir path
    FileUtils.cd path
    FileUtils.touch "Studio 60 On The Sunset Strip S01E14.avi"
    FileUtils.touch "Studio 60 On The Sunset Strip S01E15.avi"
    FileUtils.touch "studio.60.on.the.sunset.strip.s01e14.hdtv.xvid.notv.srt"
    FileUtils.touch "studio.60.on.the.sunset.strip.s01e15.hdtv.xvid.notv.srt"
  end
end

MediaScriptCLI.start(ARGV)
