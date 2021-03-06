Pod::Spec.new do |s|
  s.name = 'DataSource'
  s.version = '1.0.1'
  s.summary = 'A Swift framework that helps to deal with sectioned collections of collection items in an MVVM fashion.'
  s.homepage = 'https://github.com/thib4ult/DataSource'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = 'Vadim Yelagin'
  s.ios.deployment_target = '13.0'
  s.tvos.deployment_target = '13.0'
  s.swift_version = '5'
  s.source = { :git => 'https://github.com/thib4ult/DataSource.git', :tag => s.version }
  s.source_files = 'DataSource/**/*.swift'
end
