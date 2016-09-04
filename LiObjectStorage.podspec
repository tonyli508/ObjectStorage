Pod::Spec.new do |s|
  s.name = 'LiObjectStorage'
  s.version = '0.1.1'
  s.license = 'MIT'
  s.summary = 'ObjectStorage is a framework that make CURD works on your model entities'
  s.homepage = 'https://github.com/tonyli508/ObjectStorage'
  s.authors = { 'Li Jiantang' => 'tonyli508@gmail.com' }
  s.social_media_url = 'https://twitter.com/tonyli508'
  s.source = { :git => 'https://github.com/tonyli508/ObjectStorage.git', :tag => s.version.to_s }

  s.watchos.deployment_target = '2.0'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = 'true'
  s.source_files = 'ObjectStorage/ObjectStorage/*/*.swift', 'ObjectStorage/ObjectStorage/*.swift'
end
