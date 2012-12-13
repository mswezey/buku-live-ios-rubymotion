class CombinedPhotoList < Frequency::Base
  attr_accessor :all, :fan_photos, :pro_photos

  def initialize
    self.pro_photos = App.delegate.pro_photos_list
    self.fan_photos = App.delegate.user_photos_list
    self
  end

  def all
    @all = []
    @all << App.delegate.pro_photos_list.all[0..20]
    @all << App.delegate.user_photos_list.all[0..20]
    @all.flatten!
    @all.sort! {|a,b|  (b['fan_photo'] ? b['fan_photo']['created_at_to_i'] : b['picture']['created_at_to_i']) <=> (a['fan_photo'] ? a['fan_photo']['created_at_to_i'] : a['picture']['created_at_to_i'])}
    @all
  end

  def refresh
    App.delegate.pro_photos_list.refresh
    App.delegate.user_photos_list.refresh
  end

  def path
    ""
  end

  def filename
    "combined_photos.json"
  end

end