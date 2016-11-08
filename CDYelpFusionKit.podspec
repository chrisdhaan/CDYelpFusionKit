#
# Be sure to run `pod lib lint CDYelpFusionKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CDYelpFusionKit'
  s.version          = '0.1.0'
  s.summary          = 'An extensive Swift wrapper for the Yelp Fusion Developers V3 API.'
  s.description      = <<-DESC
This Swift wrapper covers all possible network endpoints and responses for the Yelp Fusion Developers V3 API.
                       DESC
  s.homepage         = 'https://github.com/chrisdhaan/CDYelpFusionKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source           = { :git => 'https://github.com/chrisdhaan/CDYelpFusionKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/dehaan_solo'

  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'CDYelpFusionKit/Classes/**/*'
  s.frameworks = 'CoreLocation', 'MapKit'
  s.dependency 'AlamofireObjectMapper', '~> 4.0'
end
