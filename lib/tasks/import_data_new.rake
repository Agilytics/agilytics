require 'rake'
require 'json'

namespace :import_data_new do

  ##############
  # CREATE CUBE
  desc 'import all boards'
  task :import_boards => :environment do
    puts("all boards")
  end

  def usage(from_here)
    puts "Please pass in userid (uid), password (pwd) and root URL to Jira Rest API. \n   ex: rake  import_data:#{from_here} uid=ahuffman pwd=foopass site=shareableink.atlassian.com"
  end

  #######
  # JIRA
  desc 'NEW import from jira'
  task :jira => :environment do
      if !ENV['uid'] || !ENV['pwd'] || !ENV['site']
        usage('jira')
        exit 0
      end

      puts "Connecting to site: #{ENV['site']} with uid: #{ENV['uid']} and pwd: #{ENV['pwd']}"

      rc = RestCaller.new(ENV['uid'], ENV['pwd'])
      jc = JiraCallerNew.new(rc, ENV['site'])
      jc.get_boards()
      jc.process_sprints()

  end

  ##############
  # JIRA TO FILE
  desc 'import from jira and write to cache file'
  task :jira_to_file => :environment do
      if !ENV['uid'] || !ENV['pwd'] || !ENV['site']
        usage('jira')
        exit 0
      end
      if !ENV['cacheFile']
        cacheFile = Time.new().to_s.tr(' ', '_') + '.json.txt'
      else
        cacheFile = ENV['cacheFile']
      end

      puts "Connecting to site: #{ENV['site']} with uid: #{ENV['uid']} and pwd: #{ENV['pwd']}"

      rc = RestCaller.new(ENV['uid'], ENV['pwd'])
      rc.record_in(cacheFile)
      jc = JiraCallerNew.new(rc, ENV['site'])
      jc.get_boards()
      jc.process_sprints()
      rc.end()

  end

  ##############
  # PROCESS DATA
  desc 'process_data'
  task :process_data => :environment do
    ad = AgileData.new (nil)
    ad.process_data()
  end

  ######################
  # JIRA FROM CACHE FILE
  desc 'import from jira file cached'
  task :jira_from_file => :environment do
      if !ENV['site']
        puts 'Need to specify the site.... site=https://shareableink.atlassian.net'
        exit 0
      elsif !ENV['cacheFile']
        puts 'Need to specify the cacheFile relative to the task ...  cacheFile=foo.json.txt  '
        exit 0
      else
        cacheFile = ENV['cacheFile']
      end

      puts "Will be reading from file #{cacheFile}"

      rc = RestCaller.new('foo', 'bar')
      rc.use_data_from(cacheFile)
      jc = JiraCallerNew.new(rc, ENV['site'])
      jc.get_boards()
      jc.process_sprints()
      rc.end()

  end

end