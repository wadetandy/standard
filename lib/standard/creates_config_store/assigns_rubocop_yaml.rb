require_relative "finds_rubocop_yaml"

class Standard::CreatesConfigStore
  class AssignsRubocopYaml
    def call(config_store, standard_config)
      config_store.options_config = FindsRubocopYaml.new.call(standard_config[:ruby_version])
      config_store.instance_variable_get("@options_config")
    end
  end
end
