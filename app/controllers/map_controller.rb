class MapController < UIViewController

  def loadView
    self.view = MKMapView.alloc.initWithFrame([[0,0], [320,300]])
    App.delegate.load_photographers
    App.delegate.load_map_annotations
  end

  def locatePhotographers
    App.delegate.map_annotations.refresh
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

  def addMapAnnotations
    annotations = self.view.annotations
    annotations.each do |annotation|
      self.view.removeAnnotation(annotation) #if annotation.title == 'Photographer'
    end
    App.delegate.map_annotations.all.each do |pin|
      title = pin['title']
      if pin['icon_url'].include?('stage')
        title = "#{title} Stage"
      end
      self.view.addAnnotation(MapAnnotation.new(pin['lat'], pin['lng'], title))
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
    location = CLLocationCoordinate2DMake(29.933036, -90.062057)
    region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.002, 0.002))
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

    view.image = UIImage.imageNamed('marker-pin.png') # default
    view.image = UIImage.imageNamed('tower-pin.png') if annotation.title.downcase.include?("tower")
    view.image = UIImage.imageNamed('stage-pin.png') if annotation.title.downcase.include?("stage")
    view.image = UIImage.imageNamed('photo-pin.png') if annotation.title.downcase.include?("booth")
    view.image = UIImage.imageNamed('qr-pin.png') if annotation.title.downcase.include?("qr")
    view.image = UIImage.imageNamed('touchpoint-pin.png') if annotation.title.downcase.include?("touchpoint")

    view.image = UIImage.imageNamed('photographer-pin.png') if annotation.title.downcase.include?("photographer")
    view
  end

  def viewWillAppear(animated)
    locatePhotographers
    setToolbarButtons
    # MapAnnotation::Data.each { |annotation| self.view.addAnnotation(annotation) }
  end

end