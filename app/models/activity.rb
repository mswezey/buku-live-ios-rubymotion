class Activity < Frequency::Base
  attr_accessor :activity_type, :html_string, :html_string_with_profile

  # Activity Types
  USER_SIGNED_UP    = 0
  FAN_PHOTO_POSTED  = 1
  CHECK_IN_CREATED  = 2

  def initialize(activity)
    @activity_type = activity['activity_type']
    @html_string = activity['html_string']
    @html_string_with_profile = activity['html_string_with_profile']
  end

end