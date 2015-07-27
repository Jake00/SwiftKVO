Pod::Spec.new do |s|
  s.name             = "SwiftKVO"
  s.version          = "0.1.1"
  s.summary          = "Key-Value Observing for pure Swift objects."
  s.description      = <<-DESC
                       A simple wrapper around Apple's Key-Value Observing API which enables pure Swift objects to participate in KVO updates from NSObject.
                       Also allows separate functions called for separate property updates, instead of everything being piped through observeValueForKeyPath:ofObject:.
                       DESC
  s.homepage         = "https://github.com/Jake00/SwiftKVO"
  s.license          = 'MIT'
  s.author           = { "Jake00" => "Jakeyrox@gmail.com" }
  s.source           = { :git => "https://github.com/Jake00/SwiftKVO.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes/**/*'
end
