require 'rake'
require 'json'

namespace :import_data do

  def usage(from_here)
    puts "Please pass in userid (uid), password (pwd) and root URL to Jira Rest API. \n   ex: rake  import_data:#{from_here} uid=ahuffman pwd=foopass site=shareableink.atlassian.com"
  end

  task :write_file => :environment do
    file_name = 'foooze_bar.txt'
    rio = File.open(file_name, 'w')
    #rio = IO.write('foooze_bar.txt', 'w')

    a = Hash.new()
    a['a'] = 1
    a['b'] = 1
    a['c'] = Hash.new()

    ac = a['c']

    ac['x'] = 'this is x'
    ac['y'] = 'this is y'
    ac['z'] = 'this is z'

    rio.write(a.to_json)
    rio.close()

    f = File.open(file_name, 'r')
    new_hash = JSON.load(f)
    #JSON.parse(f.readlines.to_s)

    puts(new_hash)
    puts(new_hash.to_json)

    f.close()
  end


  desc "import from jira"
  task :jira => :environment do
      if !ENV['uid'] || !ENV['pwd'] || !ENV['site']
        usage('jira')
        exit 0
      end

      puts "Connecting to site: #{ENV['site']} with uid: #{ENV['uid']} and pwd: #{ENV['pwd']}"

      rc = RestCaller.new(ENV['uid'], ENV['pwd'])
      jc = JiraCaller.new(rc, ENV['site'])
      ad = AgileData.new (jc)
      ad.create()
  end

  desc "import from jira and write to cache file"
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
      rc.recordIn(cacheFile)
      jc = JiraCaller.new(rc, ENV['site'])
      ad = AgileData.new (jc)
      ad.create()
      rc.end()

  end


  desc "import from jira file cached"
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
      rc.useDataFrom(cacheFile)
      jc = JiraCaller.new(rc, ENV['site'])
      ad = AgileData.new (jc)
      ad.create()
      rc.end()

  end



end