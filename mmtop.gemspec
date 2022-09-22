lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mmtop/version'

Gem::Specification.new do |s|
  s.name        = "mmtop"
  s.version     = MMTop::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Osheroff"]
  s.email       = ["ben@gimbo.net"]
  s.homepage    = "http://github.com/osheroff/mmtop"
  s.summary     = "A mytop-ish variant that can watch many mysql servers"

  s.add_runtime_dependency("mysql2")
  s.add_runtime_dependency("getopt-declare")
  s.add_runtime_dependency("net-ssh-gateway")
  s.add_runtime_dependency("ed25519")
  s.add_runtime_dependency("bcrypt_pbkdf")

  s.add_development_dependency("rake")
  s.add_development_dependency("bump")
  s.add_development_dependency("mysql_isolated_server")
  s.add_development_dependency("byebug")

  s.executables  << "mmtop"
  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
