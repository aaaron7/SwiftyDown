Pod::Spec.new do |s|
  s.name             = "SwiftyDown"
  s.version          = "0.0.5"
  s.summary          = "Pure swift implementation markdown parser, convert to NSAttributedString"
  s.description      = <<-DESC
                       Simple, Elegant, Powerful markdown parser written in swift. Provides friendly interface to convert markdown string to NSAttributedString.
                       DESC
  s.homepage         = "https://github.com/aaaron7/SwiftyDown"
  s.screenshots      = "https://raw.githubusercontent.com/aaaron7/SwiftyDown/master/SwiftyDownExample/screenshots.png"
  s.license          = 'LICENSE.txt'
  s.author           = { "aaaron7" => "aaaron7@outlook.com" }
  s.source           = { :git => "https://github.com/aaaron7/SwiftyDown.git", :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/roseofsharon'

  s.platform     = :ios, '8.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'SwiftyDown/*'
  # s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'UIKit'

end
