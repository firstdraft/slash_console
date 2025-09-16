require_relative "lib/slash_console/version"

Gem::Specification.new do |spec|
  spec.name = "slash_console"
  spec.version = SlashConsole::VERSION
  spec.authors = ["Raghu Betina"]
  spec.email = ["raghu@firstdraft.com"]
  spec.homepage = "https://github.com/firstdraft/slash_console"
  spec.summary = "Mountable Rails console at /rails/console"
  spec.description = "A Rails engine that provides a web-based console interface at /rails/console, with production authentication support."
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "web-console", ">= 4.0"

  spec.add_development_dependency "standard", "~> 1.0"
end
