Pod::Spec.new do |s|

  s.name         = "DJProgressHUD_OSX"
  s.version      = "0.0.1"
  s.summary      = "Progress and Activity Indicators and HUD for Mac OS X."
  s.homepage     = "https://github.com/danielmj/DJProgressHUD_OSX"
  s.license      = { :type => "GNU", :file => "LICENSE.txt" }
  s.author    = "Daniel Jackson"
  s.social_media_url   = "http://www.danmjacks.com/"
  s.platform     = :osx, "10.8"
  s.source       = { :git => "https://github.com/danielmj/DJProgressHUD_OSX.git", :tag => "0.0.1" }
  
  s.source_files  = "DJProgressHUD/*.{h,m}"
  
  s.public_header_files = "DJProgressHUD/*.h"
  
  s.framework  = "QuartzCore"
  
  s.requires_arc = true

end
