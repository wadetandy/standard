require "pathname"

class Standard::CreatesConfigStore
  class FindsRubocopYaml
    def call(desired_version)
      file_name = if desired_version < Gem::Version.new("1.9")
        "ruby-1.8.yml"
      elsif desired_version < Gem::Version.new("2.0")
        "ruby-1.9.yml"
      elsif desired_version < Gem::Version.new("2.3")
        "ruby-2.2.yml"
      else
        "base.yml"
      end

      Pathname.new(__dir__).join("../../../config/#{file_name}")
    end
  end
end
