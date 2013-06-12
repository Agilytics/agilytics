require 'rake'

namespace :import_data do

  def usage(from_here)
    puts "Please pass in userid (uid), password (pwd) and root URL to Jira Rest API. \n   ex: rake  import_data:#{from_here} uid=ahuffman pwd=foopass site=shareableink.atlassian.com"
  end


  desc "import from jira"
  task :jira => :environment do
      if !ENV['uid'] || !ENV['pwd'] || !ENV['site']
        usage('jira')

        # 'ahuffman', 'BlueBird22'
        # 'https://shareableink.atlassian.net'
        exit 0
      end

      puts "Connecting to site: #{ENV['site']} with uid: #{ENV['uid']} and pwd: #{ENV['pwd']}"

      jc = JiraCaller.new ENV['uid'], ENV['pwd'], ENV['site']
      ad = AgileData.new (jc)
      ad.create()

  end

end