class Activity < Frequency::Base
  attr_accessor :activity_type, :html_string

  # Activity Types
  USER_SIGNED_UP    = 0
  FAN_PHOTO_POSTED  = 1
  CHECK_IN_CREATED  = 2

  def initialize(activity)
    @activity_type = activity['activity_type']
    @html_string = activity['html_string']
  end

end