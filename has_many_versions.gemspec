# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_many_versions}
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joshua Hull"]
  s.date = %q{2009-04-22}
  s.email = %q{joshbuddy@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["LICENSE", "Rakefile", "README.rdoc", "VERSION.yml", "lib/has_many_versions.rb", "spec/add_spec.rb", "spec/delete_spec.rb", "spec/history_spec.rb", "spec/rollback_spec.rb", "spec/spec_helper.rb", "spec/update_spec.rb", "rails/init.rb", "spec/database.yml", "spec/spec.opts"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/joshbuddy/has_many_versions}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Versioning for has_many relationships}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
