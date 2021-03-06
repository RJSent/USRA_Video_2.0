require_relative 'lib/usra_video/version'

Gem::Specification.new do |spec|
  spec.name          = 'usra_video'
  spec.version       = UsraVideo::VERSION
  spec.authors       = ['RJSent']
  spec.email         = ['richard.j.sent@tutamail.com']
  spec.summary       = "A tool used by Cleveland State's Physics Department for analyzing SEM videos."
  spec.description   = "A tool used by Cleveland State's Physics Department for analyzing SEM videos."\
    ' The program enhances the contrast of a video, tracks the resulting particles, then outputs the'\
    ' data into a spreadsheet for analysis'

  spec.homepage      = 'https://rubygems.org/gems/usra_video'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mini_magick', '~>4.10.1'
  spec.add_runtime_dependency 'pry', '~>0.13.1'
  spec.add_runtime_dependency 'pry-doc', '~>1.1.0'
  spec.add_runtime_dependency 'ruby-opencv', '~>0.0.18'
  spec.add_runtime_dependency 'streamio-ffmpeg', '~>3.0.2'

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
end
