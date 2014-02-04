Pod::Spec.new do |s|
  s.name         = "Knobs"
  s.version      = "0.0.1"
  s.summary      = "A tool for manipulating your iOS from a desktop app."

  s.description  = <<-DESC
                   TODO
                   A longer description of Knobs in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/aleffert/knobs" #FIXME
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Akiva Leffert" => "akiva@etsy.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/aleffert/knobs.git", :commit=> "af7aacc74ae874723aacd888c21fdc7ba7b13ef0" }
  s.source_files  = 'iOS/*.[hm]', 'iOS/*/*.[hm]', 'Shared/*.[hm]', 'Shared/*/*.[hm]', 'Libraries/*/*.[hm]'
  s.public_header_files = 'iOS/Include/*.h', 'Shared/Include/*.h'
  s.preserve_paths = 'Desktop/*', 'Knobs.xcodeproj'
  s.ios.frameworks  = 'CFNetwork'
  s.requires_arc = true
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SRCROOT)/iOS/Include/' }
end
