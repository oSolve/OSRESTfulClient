#
# Be sure to run `pod lib lint OSRESTfulClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OSRESTfulClient"
  s.version          = "0.4.0"
  s.summary          = "None"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                        OSRESTfulClient is a http client obj
                       DESC

  s.homepage         = "https://github.com/oSolve/OSRESTfulClient"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "ch8908" => "kros@osolve.com" }
  s.source           = { :git => "https://github.com/oSolve/OSRESTfulClient.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'OSRESTfulClient' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'AFNetworking', '~> 2.6.0'
  s.dependency 'Mantle', '~> 2.0.5'
  s.dependency 'Bolts', '~> 1.5.0'
end
