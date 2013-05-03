Gem::Specification.new do |s|
  s.name        = "mmtop"
  s.version     = "1.0.0.rc3"
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
    s.add_development_dependency("debugger")
  end
  s.add_development_dependency("yaggy")
  s.add_development_dependency("rake")
  s.add_development_dependency("mysql_isolated_server")

  s.executables  << "mmtop"
  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
