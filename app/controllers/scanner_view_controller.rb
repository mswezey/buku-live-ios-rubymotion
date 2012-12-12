class ScannerViewController < UIViewController

  def initWithTabBar
    me = init
    me
  end

  def viewDidLoad
    self.title = "QR Scanner"
    @scanner_button = self.create_scanner_button
    self.view.addSubview(@scanner_button)

    @result_label = self.create_result_label
    self.view.addSubview(@result_label)
  end

  def viewDidDisappear(animated)
    @result_label.text = "No codes have been scanned."
  end

  def create_result_label
    label = UILabel.alloc.initWithFrame([[10, 90], [300,200]])
    label.text = "No codes have been scanned."
    label.numberOfLines = 8
    label.backgroundColor = UIColor.clearColor
    label.textColor = UIColor.whiteColor
    label.textAlignment = UITextAlignmentCenter
    label
  end

  def create_scanner_button
    button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    button.frame = [[(320 - 200)/2, 20], [200,50]]
    button.setTitle("Launch Scanner", forState:UIControlStateNormal)
    button.addTarget(self, action: 'scanner_button_tapped', forControlEvents:UIControlEventTouchUpInside)
    button.font = UIFont.fontWithName("DIN-Light", size:22)

    button
  end

  def scanner_button_tapped #(sender)
    @ZXingController = ZXingWidgetController.alloc.initWithDelegate(self, showCancel:true, OneDMode:false)

    readers = NSMutableSet.alloc.init
    readers.addObject(QRCodeReader.alloc.init)
    @ZXingController.readers = readers

    self.presentModalViewController(@ZXingController, animated:true)
  end

  def zxingController(controller, didScanResult:result)
    self.dismissModalViewControllerAnimated(true)

    data = {
      auth_token: App::Persistence['user_auth_token'],
      code: result
    }

    FRequest.new(POST, "/api/mobile/qr_scans", data, self)
    App.delegate.notificationController.setNotificationTitle "Loading"
    App.delegate.notificationController.show

    @result_label.text = ""
  end

  def request(request, didLoadResponse: response)
    data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
    error_ptr = Pointer.new(:object)
    json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
    @result_label.text = json["status"]
    App.delegate.notificationController.hide
  end

  def zxingControllerDidCancel(controller)
    self.dismissModalViewControllerAnimated(true)
  end

end
