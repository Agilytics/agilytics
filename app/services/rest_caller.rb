class RestCaller

  include HTTParty

  def initialize(uid, pwd)
    @auth = { :username => uid, :password => pwd }
  end

  def record_in(fileToSaveData)
    @record = Hash.new
    @file = File.open(fileToSaveData, 'w')
  end

  def use_data_from(file_name)
    @file = File.open(file_name, 'r')
    @responses = JSON.load(@file)
  end


  def end()
    unless @responses
      @file.write(@record.to_json)
    end
    @file.close()
  end

  def http_get(uri)
    if(@record && @record.key?(uri))
      puts("duplicate uri #{uri}")
    end

    options = {}
    options.merge!({:basic_auth => @auth})
    if(@responses && @responses.key?(uri))
        res = @responses[uri]

        class << res
          attr_accessor :code
        end

        res.code = 200

    else
      res = self.class.get(uri, options)
    end

    if(@record)
      @record[uri] = res
    end
    res
  end

end

class ClassWithCode < Hash
  attr_accessor :code
end