Pod::Spec.new do |s|
  s.name             = 'CDYelpFusionKit'
  s.version          = '1.3.0'
  s.summary          = 'An extensive Swift wrapper for the Yelp Fusion API.'
  s.description      = <<-DESC
This Swift wrapper covers all possible network endpoints and responses for the Yelp Fusion API.
                       DESC
  s.homepage         = 'https://github.com/chrisdhaan/CDYelpFusionKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source           = { :git => 'https://github.com/chrisdhaan/CDYelpFusionKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/dehaan_solo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Source/*.swift'
  s.resources = ['Resources/*.xcassets']
  s.dependency 'AlamofireObjectMapper', '4.1.0'
end
