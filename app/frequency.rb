module Frequency

  # FREQUENCY_APP_URL = 'http://www.lan-live.com'
  FREQUENCY_APP_URL = 'http://10.0.1.17:3000'

  class Base

    class << self
      attr_accessor :result
    end

    def initialize
      unless File.exists?("#{App.documents_path}/#{filename}")
        puts "#{filename} not found... creating it"
        File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write("[]")}
      end
      json_string = File.read("#{App.documents_path}/#{filename}")
      @all = BW::JSON.parse(json_string)
    end

    def self.ensuring_json(&block)
      block.call(self.result) if self.result
      request = self.new
      request.get_json do |result|
        self.result = result
        block.call(result)
      end
    end

    def base_path
      "#{FREQUENCY_APP_URL}/api/mobile"
    end

    def auth_token
      App::Persistence['user_auth_token']
    end

    def get_json_string(default="[]", &block)
      BW::HTTP.get(url) do |response|
        if response.ok?
          block.call(response.body.to_str)
        elsif response.status_code == 401
          App.alert("Login")
          block.call(default)
        else
          block.call(default)
        end
      end
    end

    def post_json(payload, default=[], &block)
      BW::HTTP.post(url, {payload: payload}) do |response|
        if response.ok?
          block.call(BW::JSON.parse(response.body.to_str))
        else
          block.call(default)
        end
      end
    end

    def refresh(default=[], &block)
      puts "refresh called"
      get_json_string do |json_string|
        @all = BubbleWrap::JSON.parse(json_string)
        File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write(json_string)}
        block.call(default) if block
      end
    end

  end

  class Authentication < Frequency::Base
    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
      true
    end

    def payload
      data = {access_token: @access_token}
    end

    def url
      "#{base_path}/authentication/facebook"
    end

    def authenticate(&block)
      puts "posting"

      BW::HTTP.post(url, {payload: payload}) do |response|
        if response.ok?
          puts "response ok"
          json = BW::JSON.parse(response.body.to_str)
          if json['status'] && json['status'] == 'success'# && json['authentication_token']
            App::Persistence['user_auth_token'] = json['authentication_token']
            puts "user auth token saved"
            block.call(true)
          else
            puts "user auth not saved"
            block.call(false)
          end
        else
          puts "response not ok"
          block.call(false)
        end
      end
    end
  end

  class FriendList < Frequency::Base
    attr_accessor :all

    def url
      "#{base_path}/#{filename}?auth_token=#{auth_token}"
    end

    def filename
      "friends.json"
    end

  end

  class Friend < Frequency::Base
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def url
      "#{base_path}/friends/#{id}.json?auth_token=#{auth_token}"
    end

  end

  class FanPhotoList < Frequency::Base
    attr_accessor :all

    def url
      "#{base_path}/fan_photos.json?auth_token=#{auth_token}"
    end

    def filename
      "fan_photos.json"
    end

  end

  class FanPhoto < Frequency::Base
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def url
      "#{base_path}/fan_photos/#{id}.json?auth_token=#{auth_token}"
    end

  end

end

