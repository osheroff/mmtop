Gem::Specification.new do |s|
  s.name        = "mmtop"
  s.version     = "0.9.4"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Osheroff"]
  s.email       = ["ben@gimbo.net"]
  s.homepage    = "http://github.com/osheroff/mmtop"
  s.summary     = "A mytop-ish variant that can watch many mysql servers"

  s.add_runtime_dependency("mysql2")
  s.add_runtime_dependency("getopt-declare")

  if RUBY_VERSION < "1.9"
    s.add_development_dependency("ruby-debug")
  else
    s.add_development_dependency("ruby-debug19")
  end

  s.executables  << "mmtop"
  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
