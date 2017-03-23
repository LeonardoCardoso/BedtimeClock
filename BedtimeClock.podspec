Pod::Spec.new do |s|
 s.name = 'BedtimeClock'
 s.version = '0.0.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'Just a bedtime clock for your app'
 s.homepage = 'https://leocardz.com'
 s.social_media_url = 'https://twitter.com/leocardz'
 s.authors = { "Leonardo Cardoso" => "leo@leocardz.com" }
 s.source = { :git => "https://github.com/leocardz.com/BedtimeClock.git", :tag => "v"+s.version.to_s }
 s.platforms     = { :ios => "8.0", :osx => "10.10", :tvos => "9.0", :watchos => "2.0" }
 s.requires_arc = true

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources/*.swift"
     ss.framework  = "Foundation"
 end

end
