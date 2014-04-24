require 'rubygems'
require 'rubygems/package_task'
require 'rake/testtask'
spec = eval(File.read('steg-client.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end