# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
# require 'motion/project'
require 'motion/project/template/ios'
require 'bundler'
require "bubble-wrap/location"
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'Buku Live!'
  app.icons = ['Icon.png', 'Icon@2x.png']
  app.prerendered_icon = true
  app.identifier = 'com.myfrequencyinc.BukuLive'
  app.sdk_version = '6.1'
  app.deployment_target = '5.1'

  app.version = '1.0'
  app.provisioning_profile = '/Users/mattswezey/Library/MobileDevice/Provisioning Profiles/D0D515EF-E47D-44FA-BA19-24AB6C8E179A.mobileprovision'
  app.codesign_certificate = 'iPhone Distribution: Frequency Incorporated'
  # app.vendor_project('vendor/zxing-2.1/iphone/ZXingWidget', :xcode, :target => 'ZXingWidget', :headers_dir => 'Classes')

  app.fonts += ["DIN-Light.ttf", "DIN-Medium.ttf", "DIN-Bold.ttf"]

  app.frameworks += %w{ UIKit Foundation AdSupport Accounts Social CoreLocation MapKit CoreData AudioToolbox CoreVideo CoreMedia AddressBook AddressBookUI QuartzCore CoreGraphics}
  app.weak_frameworks += %w{ AdSupport Accounts Social AVFoundation}
  app.libs += ['/usr/lib/libiconv.dylib']

  app.pods do
    pod 'Facebook-iOS-SDK', '~> 3.1.1'
    pod 'SDWebImage', '~> 2.7'
    pod 'KKGridView', '~> 0.6.8.2'
    # pod 'SVGKit', '~> 0.0.1'
    pod 'RestKit', '~> 0.10.1'
    pod 'SJNotificationViewController', '~> 1.0.1'
    pod 'iCarousel', '~> 1.7.2'
    pod 'SVPullToRefresh', '~> 0.4'
  end

  app.device_family          = :iphone
  app.interface_orientations = [:portrait]

  # app.info_plist['UIStatusBarHidden'] = true
  app.info_plist['UIStatusBarStyle'] = 'UIStatusBarStyleOpaqueBlack'
  app.info_plist['FacebookAppID'] = '159048010914930'
  app.info_plist['CFBundleURLTypes'] = [{'CFBundleURLSchemes' => ['fb159048010914930']}]

  app.testflight.sdk = 'vendor/TestFlight'
  app.testflight.api_token = '927f0d7d14ae638e4858645c94bb94af_NjYxMTEyMjAxMi0xMC0wNCAxNDo0Nzo0Ni4xODk3MzY'
  app.testflight.team_token = '5fccb0060699782e665b6ea51526f4ae_MTUwNDc4MjAxMi0xMS0wMSAxOToyNjoyMC41NTUxMTU'
  app.testflight.distribution_lists = ['Internal']
  app.testflight.notify = true
end
