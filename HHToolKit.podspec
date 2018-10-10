#
# Be sure to run `pod lib lint HHToolKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HHToolKit'
  s.version          = '0.1.0'
  s.summary          = 'A fast app creation toolkit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = 'A fast app creation toolkit, which allows you to build complicated UI in short time.'

  s.homepage         = 'https://github.com/weylhuang/HHKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'weylhuang' => '57029662@qq.com' }
  s.source           = { :git => 'https://github.com/weylhuang/HHKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  non_arc_files = 'HHToolKit/Classes/ASIHTTPRequest/*.{h,m}'
  s.exclude_files = non_arc_files
  
  s.subspec 'no-arc' do |sp|
      sp.requires_arc = false
      sp.source_files = non_arc_files
  end


  s.source_files = ['HHToolKit/Classes/**/*','HHToolKit/Classes/*']
  # s.resource_bundles = {
  #   'HHToolKit' => ['HHToolKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'FMDB', '2.6.2'
  s.dependency 'LKDBHelper', '2.4'
  s.dependency 'Masonry', '0.6.3'
  
end
