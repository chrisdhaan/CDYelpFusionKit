Pod::Spec.new do |s|
  s.name = 'CDYelpFusionKit'
  s.version = '2.1.1'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An extensive Swift wrapper for the Yelp Fusion API.'
  s.description = <<-DESC
  This Swift wrapper covers all possible network endpoints and responses for the Yelp Fusion API.
                         DESC
  s.homepage = 'https://github.com/chrisdhaan/CDYelpFusionKit'
  s.author = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source = { :git => 'https://github.com/chrisdhaan/CDYelpFusionKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.swift_versions = ['5.1', '5.2']

  s.source_files = 'Source/*.swift'
  s.resources = ['Resources/*.xcassets']

  s.dependency 'Alamofire', '5.2.2'
  s.dependency 'ObjectMapper', '4.2.0'
end
