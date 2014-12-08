#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'fileutils'
require 'net/http'
require 'net/https'
require 'uri'
require 'tmpdir'
require 'thread'

Dir.mktmpdir do |tmp_dir|

  GEMSERVER = "http://rubygems.org"

  # inspect Gemfile.lock
  lockfile = Bundler::LockfileParser.new(Bundler.read_file(ARGV[0]))

  to_mirror = {}

  uri = URI(GEMSERVER)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == 'https'

  requirements = {}

  lockfile.specs.each do |s|
    possible_gem_name = "#{s.name}-#{s.version.to_s}.gem"

    Dir.chdir tmp_dir do
      filename = `gem fetch #{s.name} -v #{s.version.to_s}`.split()[1]
      hash = `sha256sum #{filename}.gem`
      url = "#{GEMSERVER}/downloads/#{filename}.gem"
      puts url
      requirements[s.name] = { :version => s.version.to_s,
                               :hash => hash.split().first,
                               :url => url,}
    end
  end

  filename = ARGV[1]
  File.open(filename, 'w') do |file|
    file.puts "["
    requirements.each do |name, info|
      file.puts "{"
      file.puts ['name = ', '"', name, '";'].join('')
      file.puts ['hash = ', '"', info[:hash], '";'].join('')
      file.puts ['url = ', '"', info[:url], '";'].join('')
      file.puts ['version = ', '"', info[:version], '";'].join('')
      file.puts "}"
    end
    file.puts "]"
  end

end
