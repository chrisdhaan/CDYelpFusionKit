Pod::Spec.new do |s|
  s.name = 'CDYelpFusionKit'
  s.version = '4.0.0'
  s.cocoapods_version = '>= 1.13.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An extensive Swift wrapper for the Yelp Fusion API.'
  s.description = <<-DESC
    This Swift wrapper covers all possible network endpoints and responses for the Yelp Fusion API.
  DESC
  s.homepage = 'https://github.com/chrisdhaan/CDYelpFusionKit'
  s.author = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source = { :git => 'https://github.com/chrisdhaan/CDYelpFusionKit.git', :tag => s.version.to_s }
  s.documentation_url = 'https://chrisdhaan.github.io/CDYelpFusionKit/'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '11.0'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '4.0'
  s.visionos.deployment_target = '1.0'

  s.swift_versions = ['5']

  s.source_files = 'Source/*.swift'
  s.resource_bundles = { 'CDYelpFusionKit' => ['Source/PrivacyInfo.xcprivacy'] }
  s.resources = ['Resources/*.xcassets']

  s.dependency 'Alamofire', '~> 5.9'
end
