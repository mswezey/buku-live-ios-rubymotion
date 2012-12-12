class FanPhoto < Frequency::Base
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def path
    "#{base_path}/fan_photos/#{id}" #.json?auth_token=#{auth_token}"
  end

  def destroy(&block)
    RKClient.sharedClient.delete(path, usingBlock:block)
  end

end