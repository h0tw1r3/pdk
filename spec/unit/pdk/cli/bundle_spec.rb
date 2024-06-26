require 'spec_helper'
require 'pdk/cli'

describe 'Running `pdk bundle`' do
  let(:command_args) { ['bundle'] }
  let(:command_result) { { exit_code: 0 } }

  context 'when it calls bundler successfully' do
    before do
      mock_command = instance_double(
        PDK::CLI::Exec::InteractiveCommand,
        :context= => true,
        :update_environment => true,
        :execute! => command_result
      )
      allow(PDK::CLI::Exec::InteractiveCommand).to receive(:new)
        .with(PDK::CLI::Exec.bundle_bin, *(command_args[1..] || []))
        .and_return(mock_command)

      allow(PDK::Util).to receive(:module_root)
        .and_return(File.join('path', 'to', 'test', 'module'))
      allow(PDK::Module::Metadata).to receive(:from_file)
        .with('metadata.json').and_return({})
      allow(PDK::CLI::Util).to receive(:puppet_from_opts_or_env)
        .and_return(ruby_version: '2.4.3', gemset: { puppet: '5.4.0' })
      allow(PDK::Util::RubyVersion).to receive(:use)
    end

    context 'and called with no arguments' do
      it 'runs without an error' do
        expect do
          PDK::CLI.run(command_args)
        end.to exit_zero
      end
    end

    context 'and called with a bundler subcommand that is not "exec"' do
      let(:command_args) { super() + ['config', 'something'] }

      it 'runs without an error' do
        expect do
          PDK::CLI.run(command_args)
        end.to exit_zero
      end
    end

    context 'and called with the "exec" bundler subcommand' do
      let(:command_args) { super() + ['exec', 'rspec', 'some/path'] }

      it 'runs without an error' do
        expect do
          PDK::CLI.run(command_args)
        end.to exit_zero
      end
    end
  end
end
