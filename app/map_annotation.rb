class MapAnnotation

  def initialize(latitude, longitude, name, icon="marker")
    @name = name
    @coordinate = CLLocationCoordinate2D.new(latitude, longitude)
    @icon = icon
  end

  def title; @name; end
  def coordinate; @coordinate; end

  def icon
    case @icon
    when "stage"
      'stage-pin.png'
    when "tower"
      'tower-pin.png'
    when "booth"
      'photo-pin.png'
    when "photographer"
      'photographer-pin.png'
    when 'qr'
      'qr-pin.png'
    when 'touchpoint'
      'touchpoint-pin.png'
    else
      'marker-pin.png'
    end
  end

  # Data = [
  #   MapAnnotation.new(32.77997, -96.762198, 'Tower 1'),
  #   MapAnnotation.new(32.78141, -96.761656, 'Tower 2'),
  #   MapAnnotation.new(32.78085, -96.762633, 'Photo Booth'),
  #   MapAnnotation.new(32.78210, -96.76131, 'Main Stage'),
  #   MapAnnotation.new(32.78234, -96.76344, 'Club Lights All Night Stage'),
  #   MapAnnotation.new(32.78111, -96.76455, 'Hangar Stage'),
  #   MapAnnotation.new(32.78102, -96.76205, 'Fountain Stage')
  # ]

# 1 NW
# 2 NE
# 3 SE
# 4 SW

end