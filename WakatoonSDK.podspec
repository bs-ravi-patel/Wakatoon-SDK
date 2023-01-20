Pod::Spec.new do |spec|
 
  spec.name             = "WakatoonSDK"
  spec.version          = "1.0"
  spec.summary		= "It is Story Maker xcFramework."
  spec.description      = "It is Story Maker xcFramework with Wakatoon App."			

  spec.homepage         = "https://github.com/ravipatel-123/Wakatoon-SDK"
  spec.authors          = { 'Ravi Patel' => 'ravipatel@bombaysoftware.com' }  
  spec.license          = { :type => 'MIT' }
  spec.source           = { :git => 'https://github.com/ravipatel-123/Wakatoon-SDK.git', :tag => spec.version }

  spec.source_files = "wakatoonSDK", "wakatoonSDK/**/*.{h,m}"
  spec.swift_version = '5.0'
  spec.ios.deployment_target  = '12.0'

end