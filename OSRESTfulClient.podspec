#
# Be sure to run `pod lib lint OSRESTfulClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OSRESTfulClient'
  s.version          = '0.8.0'
  s.summary          = 'None'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                         OSRESTfulClient is a http client obj
                       DESC

  s.homepage         = 'https://github.com/oSolve/OSRESTfulClient'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "ch8908" => "kros@osolve.com" }
  s.source           = { :git => 'https://github.com/oSolve/OSRESTfulClient.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'OSRESTfulClient/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OSRESTfulClient' => ['OSRESTfulClient/Assets/*.png']
  # }

  s.public_header_files = 'OSRESTfulClient/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'Mantle', '~> 2.0.7'
  s.dependency 'Bolts', '~> 1.7.0'
end
