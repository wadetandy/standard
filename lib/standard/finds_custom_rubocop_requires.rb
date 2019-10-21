require "pathname"

module Standard
  class FindsCustomRubocopRequires
    def call
      standard_support_files + custom_cops
    end

    private

    def custom_cops
      cops_dir = Pathname.new(__dir__).join("./cop/**/*")

      Dir.glob(cops_dir).select { |f| File.file?(f) }
    end

    def standard_support_files
      formatter = Pathname.new(__dir__).join("./formatter.rb").to_s

      [formatter]
    end
  end
end
