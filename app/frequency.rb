module Frequency

  FREQUENCY_APP_URL = 'http://www.lan-live.com'
  # FREQUENCY_APP_URL = 'http://10.0.1.17:3000'

  class Base

    class << self
      attr_accessor :result
    end

    def initialize
      NSLog("INITIALIZE")
      check_cache_file
      load_local_cache_file
      if @all == nil
        puts "file corruption detected, recreating local cache file..."
        create_local_cache_file
        load_local_cache_file
        if @all == nil
          puts "cannot load local cache file"
          @all = [] # prevent nil and wait for refresh
        end
      end
      NSLog("AFTER INITIALIZE")
      self
    end

    def handle_unauthorized_response
      App.delegate.unauthorized_count += 1
      NSLog("****** UNAUTHORIZED ATTEMPT #{App.delegate.unauthorized_count} ******")
      if App.delegate.unauthorized_count > 5
        NSLog("GIVING UP AFTER UNAUTHORIZED")
        App.alert("Session Expired. Please login again.")
        App.delegate.closeSession
        App.delegate.show_login_modal
        App.delegate.unauthorized_count = 0
        App.delegate.notificationController.hide
      else
        NSLog("REFRESH AFTER UNAUTHORIZED")
        refresh
      end
    end

    def check_cache_file
      NSLog("CHECK CACHE FILE")
      unless File.exists?("#{App.documents_path}/#{filename}")
        NSLog("FILE NOT FOUND")
        puts "#{filename} not found... creating it"
        create_local_cache_file
      end
      NSLog("END CHECK CACHE FILE")
    end

    def create_local_cache_file
      NSLog("START CREATE LOCAL FILE")
      return false unless filename
      File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write("[]")}
      NSLog("END CREATE LOCAL CACHE FILE")
    end

    def load_local_cache_file
      NSLog("START LOAD CACHE FILE")
      return false unless filename
      puts "loading local cache file #{filename}..."
      NSLog("READING FILE")
      data = File.read("#{App.documents_path}/#{filename}").dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      NSLog("JSON OBJECT CREATION")
      @all = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      NSLog("END LOAD LOCAL CACHE FILE")
    end

    def base_path
      "/api/mobile"
    end

    def params
      {auth_token: auth_token}
    end

    def auth_token
      App::Persistence['user_auth_token']
    end

    def refresh
      puts "base refresh called"
      FRequest.new(GET, path, nil, self)
      App.delegate.notificationController.setNotificationTitle "Loading #{loading_title}"
      App.delegate.notificationController.show
    end

    def request(request, didLoadResponse: response)
      puts "new response called"
      App.delegate.unauthorized_count = 0
      data = response.bodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
      error_ptr = Pointer.new(:object)
      @all = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
      File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write(response.bodyAsString)}
      App.delegate.notificationController.hide
    end

    def request(request, didFailWithError:error)
      puts "base request response error: #{error}"
    end

  end

  class Authentication < Frequency::Base
    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
      true
    end

    def params
      data = {access_token: @access_token}
    end

    def path
      "#{base_path}/authentication/facebook"
    end

  end

end

module FUI

  class KenBurnsView < UIView

    def init
      if super
        NSLog("KENBURNSVIEW INIT")
        self.layer.masksToBounds = true
      end
      self
    end

    def initWithFrame(frame)
      if super
        NSLog("KENBURNSVIEW INIT WITH FRAME")
        self.layer.masksToBounds = true
      end
      self
    end

    def animateWithImages(images, transitionDuration:duration, loop:shouldLoop, isLandscape:inLandscape)
      @imageViewsArray  = images
      @timeTransition   = duration
      @isLoop           = shouldLoop
      @isLandscape      = inLandscape
      @animating        = false

      self.layer.masksToBounds = true

      NSThread.detachNewThreadSelector("startAnimations:", toTarget:self, withObject:images)
    end

    def animateWithUrls(urls, transitionDuration:duration, loop:shouldLoop, isLandscape:inLandscape)
      @urls             = urls
      @imagesArray      = []
      @timeTransition   = duration
      @isLoop           = shouldLoop
      @isLandscape      = inLandscape
      @animating        = false

      self.layer.masksToBounds = true

      NSThread.detachNewThreadSelector("startUrlAnimations:", toTarget:self, withObject:urls)
    end

    def startUrlAnimations(urls)

    end

    def startAnimations(images)
      NSLog("START ANIMATIONS")
      @animating = true
      i = 0
      while i < images.size && @animating == true
        self.performSelectorOnMainThread("animate:",
                                 withObject:i,
                              waitUntilDone:true)

          sleep @timeTransition

        i = (i == images.size - 1) && @isLoop ? -1 : i
        i+=1
      end
      NSLog("AFTER START ANIMATIONS")
    end

    def stopAnimating
      @animating = false
    end

    def resumeAnimating
      @animating = true
    end

    def animate(num)
      # image = UIImage.imageWithData(data)
      imageView = @imageViewsArray[num]
      return unless imageView
      image = imageView.image

      frameWidth    = self.frame.size.width
      frameHeight   = self.frame.size.height

      if (image.size.width > frameWidth)
        widthDiff  = image.size.width - frameWidth;
        # Higher than screen
        if (image.size.height > frameHeight)
          heightDiff = image.size.height - frameHeight;
          if (widthDiff > heightDiff)
              resizeRatio = frameHeight / image.size.height;
          else
              resizeRatio = frameWidth / image.size.width;
          end
          # No higher than screen
        else
          heightDiff = frameHeight - image.size.height;

          if (widthDiff > heightDiff)
              resizeRatio = frameWidth / image.size.width;
          else
              resizeRatio = self.bounds.size.height / image.size.height;
          end
        end
          # No widder than screen
      else
        widthDiff  = frameWidth - image.size.width;

        # Higher than screen
        if (image.size.height > frameHeight)
          heightDiff = image.size.height - frameHeight;

          if (widthDiff > heightDiff)
              resizeRatio = image.size.height / frameHeight;
          else
              resizeRatio = frameWidth / image.size.width;
          end
          # No higher than screen
        else
          heightDiff = frameHeight - image.size.height;

          if (widthDiff > heightDiff)
              resizeRatio = frameWidth / image.size.width;
          else
              resizeRatio = frameHeight / image.size.height;
          end
        end
      end

      enlargeRatio = 1.2

      optimusWidth  = (image.size.width * resizeRatio) * enlargeRatio
      optimusHeight = (image.size.height * resizeRatio) * enlargeRatio

      @imageView = UIImageView.alloc.initWithFrame([[0,0],[optimusWidth, optimusHeight]])

      maxMoveX = optimusWidth - frameWidth;
      maxMoveY = optimusHeight - frameHeight;

      case rand(3)
      when 0
        # puts "animation 0"
        originX = 0
        originY = 0
        zoomInX = 1.25
        zoomInY = 1.25
        moveX   = -maxMoveX
        moveY   = -maxMoveY
      when 1
        # puts "animation 1"
        originX = 0;
        originY = frameHeight - optimusHeight;
        zoomInX = 1.10;
        zoomInY = 1.10;
        moveX   = -maxMoveX;
        moveY   = maxMoveY;
      when 2
        # puts "animation 2"
        originX = frameWidth - optimusWidth;
        originY = 0;
        zoomInX = 1.30;
        zoomInY = 1.30;
        moveX   = maxMoveX;
        moveY   = -maxMoveY;
      when 3
        # puts "animation 3"
        originX = frameWidth - optimusWidth;
        originY = frameHeight - optimusHeight;
        zoomInX = 1.20;
        zoomInY = 1.20;
        moveX   = maxMoveX;
        moveY   = maxMoveY;
      end

      picLayer = CALayer.layer
      picLayer.contents    = image.CGImage
      picLayer.anchorPoint = CGPointMake(0, 0)
      picLayer.bounds      = CGRectMake(0, 0, optimusWidth, optimusHeight);
      picLayer.position    = CGPointMake(originX, originY);

      @imageView.layer.addSublayer(picLayer)

      animation = CATransition.animation
      animation.setDuration(1)
      animation.setType("kCATransitionFade")
      self.layer.addAnimation(animation, forKey:nil)

      if (self.subviews.count > 0)
        self.subviews.objectAtIndex(0).removeFromSuperview
      end

      self.addSubview(@imageView)

      rotation = (rand(9) / 100.to_f)
      rotate    = CGAffineTransformMakeRotation(rotation)
      moveRight = CGAffineTransformMakeTranslation(moveX, moveY)
      combo1    = CGAffineTransformConcat(rotate, moveRight)
      zoomIn    = CGAffineTransformMakeScale(zoomInX, zoomInY)
      transform = CGAffineTransformConcat(zoomIn, combo1)
      UIView.animateWithDuration(@timeTransition+2,
        delay:0,
        options: UIViewAnimationCurveEaseIn,
        animations: lambda {
          @imageView.transform = transform
        },
        completion:nil
      )
    end

  end

  class GemFacetView < UIView
    attr_accessor :points

    POINTS_THRESHOLD = 15000.0

    def initWithFrame(frame)
      if super
        self.backgroundColor = UIColor.clearColor
        self.layer.setMasksToBounds(true)
        setupMask
      end
      self
    end

    def points=(points)
      @points = points
      @maskFrame ||= @maskLayer.frame
      total = @maskFrame.size.height
      points = points.to_f
      change_y = (total * points) / POINTS_THRESHOLD
      new_y = total - change_y
      new_y = new_y < 0 ? 0 : new_y # stop moving up once threshold reached

      UIView.animateWithDuration(2,
        delay:0,
        options: UIViewAnimationCurveEaseIn ,
        animations: lambda {
          @maskLayer.frame = [[@maskFrame.origin.x, new_y], [@maskFrame.size.width, @maskFrame.size.height]]
        },
        completion:nil
      )
    end

    def setupMask
      @maskLayer ||= begin
        maskLayer = CALayer.layer
        maskLayer.frame = [[0,self.frame.size.height],[self.frame.size.width, self.frame.size.height]]
        maskLayer.backgroundColor = UIColor.blackColor.CGColor
        self.layer.setMask(maskLayer)
        maskLayer
      end
    end
  end

end