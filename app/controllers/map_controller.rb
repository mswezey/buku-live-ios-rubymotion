class MapController < UIViewController

  def loadView
    self.view = MKMapView.alloc.initWithFrame([[0,0], [320,300]])
    App.delegate.load_photographers
  end

  def locatePhotographers
    App.delegate.photographers.refresh
  end

  def addPhotographers
    annotations = self.view.annotations
    annotations.each do |annotation|
      self.view.removeAnnotation(annotation) if annotation.title == 'Photographer'
    end
    App.delegate.photographers.all.each do |photog|
      self.view.addAnnotation(MapAnnotation.new(photog['lat'], photog['lng'], 'Photographer'))
    end
  end

  def centerOnUser
    if self.view.userLocation.location
      self.view.centerCoordinate = self.view.userLocation.location.coordinate
    else
      App.alert("Turn on location services to see yourself on the map.")
    end
  end

  def centerOnFestival
    location = CLLocationCoordinate2DMake(32.78117, -96.76286)
    region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.004, 0.004))
    self.view.setRegion(region)
  end

  def setToolbarButtons
    buttons = []

    flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemFlexibleSpace, target:nil, action:nil)

    festival_location_button = UIBarButtonItem.alloc.initWithTitle("Festival", style:UIBarButtonItemStyleDone, target:self, action:'centerOnFestival')
    user_location_button = UIBarButtonItem.alloc.initWithTitle("Me", style:UIBarButtonItemStyleDone, target:self, action:'centerOnUser')
    refresh_button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemRefresh, target:self, action:'locatePhotographers')

    buttons << flexibleSpace
    buttons << festival_location_button
    buttons << user_location_button
    buttons << refresh_button

    App.delegate.navToolbar.setItems(buttons, animated:false)
  end

  def viewDidLoad
    setToolbarButtons
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithCustomView(App.delegate.navToolbar)

    self.view.mapType = MKMapTypeStandard
    centerOnFestival

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view.showsUserLocation = true
    self.view.delegate = self
  end

  ViewIdentifier = 'ViewIdentifier'
  def mapView(mapView, viewForAnnotation:annotation)

    existing = mapView.dequeueReusableAnnotationViewWithIdentifier(ViewIdentifier)

    return nil if annotation.isKindOfClass(MKUserLocation)
    if existing != nil && existing != ""
      view = existing
      view.annotation = annotation
    else
      view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:ViewIdentifier)
    end
    view.canShowCallout = true
    view.image = UIImage.imageNamed('tower-pin.png') if ['Tower 1', 'Tower 2'].include? annotation.title
    view.image = UIImage.imageNamed('stage-pin.png') if ['Main Stage', 'Club Lights All Night Stage', 'Hangar Stage', 'Fountain Stage'].include? annotation.title
    view.image = UIImage.imageNamed('photo-pin.png') if ['Photo Booth'].include? annotation.title
    view.image = UIImage.imageNamed('photographer-pin.png') if ['Photographer'].include? annotation.title
    view
  end

  def viewWillAppear(animated)
    locatePhotographers
    setToolbarButtons
    MapAnnotation::Data.each { |annotation| self.view.addAnnotation(annotation) }

    clan_stage_points = [CLLocationCoordinate2D.new(32.78189742109183, -96.76289283227057), CLLocationCoordinate2D.new(32.78235845662619, -96.76272275921521), CLLocationCoordinate2D.new(32.78267783865516, -96.76386342585194),CLLocationCoordinate2D.new(32.78220100192807, -96.76404289237752),CLLocationCoordinate2D.new(32.78189742109183, -96.76289283227057)]

    clan_stage_pointer = Pointer.new(CLLocationCoordinate2D.type, clan_stage_points.length)
    clan_stage_points.each_with_index do |point, i|
      clan_stage_pointer[i] = clan_stage_points[i]
    end

    clan_stage = MKPolygon.polygonWithCoordinates(clan_stage_pointer, count:clan_stage_points.length)
    clan_stage.title = "Club Lights All Night Stage"
    self.view.addOverlay(clan_stage)

    main_stage_points = [CLLocationCoordinate2D.new(32.7819454453772, -96.76172089966691), CLLocationCoordinate2D.new(32.78165495933061, -96.7605910214524), CLLocationCoordinate2D.new(32.78204277128738, -96.76045675782352),CLLocationCoordinate2D.new(32.78232510066122, -96.76157637626099),CLLocationCoordinate2D.new(32.7819454453772, -96.76172089966691)]

    main_stage_pointer = Pointer.new(CLLocationCoordinate2D.type, main_stage_points.length)
    main_stage_points.each_with_index do |point, i|
      main_stage_pointer[i] = main_stage_points[i]
    end

    main_stage = MKPolygon.polygonWithCoordinates(main_stage_pointer, count:main_stage_points.length)
    main_stage.title = "Main Stage"
    self.view.addOverlay(main_stage)


    hangar_stage_points = [CLLocationCoordinate2D.new(32.78118412161275, -96.76465400901228), CLLocationCoordinate2D.new(32.78088481257544, -96.76478993677303), CLLocationCoordinate2D.new(32.7807119098693, -96.76410324439348),CLLocationCoordinate2D.new(32.78102531197486, -96.76397640428462),CLLocationCoordinate2D.new(32.78118412161275, -96.76465400901228)]

    hangar_stage_pointer = Pointer.new(CLLocationCoordinate2D.type, hangar_stage_points.length)
    hangar_stage_points.each_with_index do |point, i|
      hangar_stage_pointer[i] = hangar_stage_points[i]
    end

    hangar_stage = MKPolygon.polygonWithCoordinates(hangar_stage_pointer, count:hangar_stage_points.length)
    hangar_stage.title = "Hangar Stage"
    self.view.addOverlay(hangar_stage)

    fountain_stage_points = [CLLocationCoordinate2D.new(32.78072341674939, -96.7620710081754), CLLocationCoordinate2D.new(32.78128100822693, -96.76185835810534), CLLocationCoordinate2D.new(32.78135322292454, -96.76213591486209),CLLocationCoordinate2D.new(32.78079997958856, -96.76234801922263),CLLocationCoordinate2D.new(32.78072341674939, -96.7620710081754)]

    fountain_stage_pointer = Pointer.new(CLLocationCoordinate2D.type, fountain_stage_points.length)
    fountain_stage_points.each_with_index do |point, i|
      fountain_stage_pointer[i] = fountain_stage_points[i]
    end

    fountain_stage = MKPolygon.polygonWithCoordinates(fountain_stage_pointer, count:fountain_stage_points.length)
    fountain_stage.title = "Fountain Stage"
    self.view.addOverlay(fountain_stage)
  end

  def mapView(mapView, viewForOverlay:overlay)
    aView = MKPolygonView.alloc.initWithPolygon(overlay)
    case overlay.title
    when "Club Lights All Night Stage"
      aView.fillColor = '#ff2121'.to_color.colorWithAlphaComponent(0.2)
      aView.strokeColor = '#ac0000'.to_color.colorWithAlphaComponent(0.7)
    when "Main Stage"
      aView.fillColor = '#00d6fb'.to_color.colorWithAlphaComponent(0.2)
      aView.strokeColor = '#007582'.to_color.colorWithAlphaComponent(0.7)
    when "Hangar Stage"
      aView.fillColor = '#35fe60'.to_color.colorWithAlphaComponent(0.2)
      aView.strokeColor = '#007b22'.to_color.colorWithAlphaComponent(0.7)
    when "Fountain Stage"
      aView.fillColor = '#ffca5c'.to_color.colorWithAlphaComponent(0.2)
      aView.strokeColor = '#7b4f16'.to_color.colorWithAlphaComponent(0.7)
    else
      aView.fillColor = UIColor.cyanColor.colorWithAlphaComponent(0.2)
      aView.strokeColor = UIColor.blueColor.colorWithAlphaComponent(0.7)
    end
    aView.lineWidth = 1

    # aView = LanMapView.alloc.initWithOverlay(overlay)

    return aView
  end

end