require "rubocop/daemon"
require_relative "../finds_custom_rubocop_requires"

require "pry"
module Standard
  module Runners
    class RubocopDaemon
      def call(config)
        rubocop_opts = config.rubocop_options.dup

        config_file = CreatesConfigStore::FindsRubocopYaml.new.call(config.standard_options[:ruby_version])

        args = ["-c", config_file.to_s]

        FindsCustomRubocopRequires.new.call.each do |ruby_file|
          args += ["--require", ruby_file]
        end

        rubocop_opts.delete(:formatters).each do |(formatter, _)|
          args += ["--format", formatter]
        end
        rubocop_opts.delete(:format)

        rubocop_opts.each_pair do |opt, val|
          if val
            args += ["--#{opt.to_s.tr("_", "-")}"]
          end
        end

        args += config.paths

        daemon_exec = ExecCommand.new(["--"] + args)
        daemon_exec.run(rubocop_opts[:stdin])
      end

      private

      class ExecCommand < RuboCop::Daemon::ClientCommand::Exec
        Cache = RuboCop::Daemon::Cache
        def run(stdin)
          args = parser.parse(@argv)
          ensure_server!
          Cache.status_path.delete if Cache.status_path.file?

          response = send_request(
            command: "exec",
            args: args,
            body: stdin,
          )

          parse_status == 0
        end

        private

        def parse_status
          raise "rubocop-daemon: Could not find status file at: #{Cache.status_path}" unless Cache.status_path.file?

          status = Cache.status_path.read
          raise "rubocop-daemon: '#{status}' is not a valid status!" if (status =~ /^\d+$/).nil?

          status.to_i
        end
      end
    end
  end
end
