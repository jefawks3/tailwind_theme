# frozen_string_literal: true

require_relative "lib/tailwind_theme/version"

Gem::Specification.new do |spec|
  spec.name = "tailwind_theme"
  spec.version = TailwindTheme::VERSION
  spec.authors = ["James Fawks"]
  spec.email = ["hello@jfawks.com"]

  spec.summary = "A small Tailwind CSS theme utility to read and apply themes stored in a YAML file."
  spec.homepage = "https://github.com/jefawks3"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jefawks3"
  spec.metadata["changelog_uri"] = "https://github.com/jefawks3/releases"

  spec.files = Dir["LICENSE", "README.md", "lib/**/*"]
  spec.test_files = Dir["spec/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "tailwind_merge", "~> 0.10"
end
