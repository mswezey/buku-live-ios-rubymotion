class ProPhoto < Frequency::Base
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def path
    "#{base_path}/pro_photos/#{id}"
  end

end