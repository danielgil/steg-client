Gem::Specification.new do |s|
  s.name        = 'steg-client'
  s.version     = '0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Daniel Gil']
  s.email       = ['daniel.gil.bayo@gmail.com']
  s.homepage    = 'http://www.naildrivin5.com/todo'
  s.summary     = %q{Client component of the HTTP Steganography project}
  s.description = %q{}
  s.files       = ['bin/steg-client']
  s.executables = ['steg-client']
  s.add_dependency('gli')
end