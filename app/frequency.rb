module Frequency

  FREQUENCY_APP_URL = 'http://www.lan-live.com'
  # FREQUENCY_APP_URL = 'http://10.0.1.17:3000'

  class Base

    class << self
      attr_accessor :result
    end

    def initialize
      unless File.exists?("#{App.documents_path}/#{filename}")
        puts "#{filename} not found... creating it"
        File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write("[]")}
      end
      json_string = File.read("#{App.documents_path}/#{filename}")
      @all = BW::JSON.parse(json_string)
    end

    def self.ensuring_json(&block)
      block.call(self.result) if self.result
      request = self.new
      request.get_json do |result|
        self.result = result
        block.call(result)
      end
    end

    def base_path
      "#{FREQUENCY_APP_URL}/api/mobile"
    end

    def auth_token
      App::Persistence['user_auth_token']
    end

    def get_json_string(default="[]", &block)
      BW::HTTP.get(url) do |response|
        if response.ok?
          block.call(response.body.to_str)
        elsif response.status_code == 401
          App.delegate.closeSession
          App.delegate.show_login_modal
          App.alert("Please login again")
          block.call(default)
        else
          block.call(default)
        end
      end
    end

    def post_json(payload, default=[], &block)
      BW::HTTP.post(url, {payload: payload}) do |response|
        if response.ok?
          block.call(BW::JSON.parse(response.body.to_str))
        else
          block.call(default)
        end
      end
    end

    def refresh(default=[], &block)
      puts "refresh called"
      get_json_string do |json_string|
        @all = BubbleWrap::JSON.parse(json_string)
        File.open("#{App.documents_path}/#{filename}", "w") {|f| f.write(json_string)}
        block.call(default) if block
      end
    end

  end

  class Authentication < Frequency::Base
    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
      true
    end

    def payload
      data = {access_token: @access_token}
    end

    def url
      "#{base_path}/authentication/facebook"
    end

    # def authenticate(&block)
    #   puts "posting"

    #   BW::HTTP.post(url, {payload: payload}) do |response|
    #     if response.ok?
    #       puts "response ok"
    #       json = BW::JSON.parse(response.body.to_str)
    #       if json['status'] && json['status'] == 'success'# && json['authentication_token']
    #         App::Persistence['user_auth_token'] = json['authentication_token']
    #         puts "user auth token saved"
    #         block.call(true)
    #       else
    #         puts "user auth not saved"
    #         block.call(false)
    #       end
    #     else
    #       puts "response not ok"
    #       block.call(false)
    #     end
    #   end
    # end

  end

  class User < Frequency::Base
    attr_accessor :attributes, :profile_image_url, :total_points, :points_checkins, :points_photos, :points_badges

    def initialize
      refresh
    end

    def refresh(&block)
      puts "refresh user"
      get_json_string do |json_string|
        @attributes = BubbleWrap::JSON.parse(json_string)
        update_points
        block.call(true) if block
      end
    end

    def update_points
      self.points_checkins = @attributes['points_from_checkins']
      self.points_badges = @attributes['points_from_badges']
      self.points_photos = @attributes['points_from_photos']
    end

    def url
      "#{base_path}/me.json?auth_token=#{auth_token}"
    end

    def profile_image_url
      @profile_image_url = App::Persistence['user_profile_image_url']
    end

    def points_checkins=(points_checkins)
      App::Persistence['points_checkins'] = points_checkins.to_i
      set_points
    end

    def points_photos=(points_photos)
      App::Persistence['points_photos'] = points_photos.to_i
      set_points
    end

    def points_badges=(points_badges)
      App::Persistence['points_badges'] = points_badges.to_i
      set_points
    end

    def points_checkins
      App::Persistence['points_checkins']
    end

    def points_photos
      App::Persistence['points_photos']
    end

    def points_badges
      App::Persistence['points_badges']
    end

    def total_points
      @points_checkins + @points_photos + @points_badges
    end

    def set_points
      App.delegate.my_points_view.setPoints(points_checkins, points_badges, points_photos)
      App.delegate.points_label.text = App.delegate.my_points_view.total_points_formatted
    end

  end

  class FriendList < Frequency::Base
    attr_accessor :all

    def url
      "#{base_path}/#{filename}?auth_token=#{auth_token}"
    end

    def filename
      "friends.json"
    end

  end

  class Friend < Frequency::Base
    attr_accessor :id, :attributes, :photos

    def initialize(id)
      @id = id
    end

    def refresh(&block)
      get_json_string do |json_string|
        @attributes = BubbleWrap::JSON.parse(json_string)
        block.call(true) if block
      end
    end

    def url
      "#{base_path}/friends/#{@id}.json?auth_token=#{auth_token}"
    end

    def photos
      @attributes
    end


  end

  class FanPhotoList < Frequency::Base
    attr_accessor :all

    def url
      "#{base_path}/fan_photos.json?auth_token=#{auth_token}"
    end

    def filename
      "fan_photos.json"
    end

  end

  class FanPhoto < Frequency::Base
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def url
      "#{base_path}/fan_photos/#{id}.json?auth_token=#{auth_token}"
    end

  end

  class PhotographerList < Frequency::Base
    attr_accessor :all

    def initialize
    end

    def refresh(&block)
      get_json_string do |json_string|
        @all = BubbleWrap::JSON.parse(json_string)
        block.call(true) if block
      end
    end

    def url
      "#{base_path}/photographers.json?auth_token=#{auth_token}"
    end

  end

end

module FUI

  class KenBurnsView < UIView

    def init
      if super
        self.layer.masksToBounds = true
      end
      self
    end

    def initWithFrame(frame)
      if super
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

    POINTS_THRESHOLD = 5000.0

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