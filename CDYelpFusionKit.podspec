Pod::Spec.new do |s|
  s.name = 'CDYelpFusionKit'
  s.version = '6.0.1'
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

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.tvos.deployment_target = '15.0'
  s.watchos.deployment_target = '8.0'
  s.visionos.deployment_target = '1.0'

  s.swift_versions = ['5']

  s.default_subspec = 'Core'

  s.subspec 'Core' do |c|
    c.source_files = 'Source/**/*.swift'
    c.exclude_files = ['Source/CDYelpMockClientFactory.swift', 'Source/CDYelpMockURLProtocol.swift']
    c.resource_bundles = { 'CDYelpFusionKit' => ['Source/PrivacyInfo.xcprivacy'] }
    c.resources = ['Resources/*.xcassets']
  end

  s.subspec 'Testing' do |t|
    t.source_files = ['Source/CDYelpMockClientFactory.swift', 'Source/CDYelpMockURLProtocol.swift']
    t.dependency 'CDYelpFusionKit/Core'
  end
end
