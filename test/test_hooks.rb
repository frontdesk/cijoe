require 'helper'

# mock files to true
class File
  class << self
    alias orig_exists? exists?
    alias orig_executable? executable?

    def exists?(f)
      return true if $hook_override
      orig_exists? f
    end
    def executable?(f)
      return true if $hook_override
      orig_executable? f
    end
  end
end

# #mock file to be the file I want
class CIJoe
  attr_writer :last_build
  alias orig_path_in_project path_in_project

  def path_in_project(f)
    return '/tmp/test' if $hook_override
    orig_path_in_project
  end

end

class CIJoe::Git
  alias orig_user_and_project user_and_project

  def user_and_project
    return ['mine','yours'] if $hook_override
    orig_user_and_project
  end
end

class CIJoe::Commit
  attr_writer :raw_commit
end



describe 'hooks' do
  def teardown
    $hook_override = nil
  end

  def setup
    $hook_override = true
    open("/tmp/test",'w') do |file|
      file.write "echo $test\n"
      file.write "echo $AUTHOR\n"
      file.write "export test=foo\n"
    end
    File.chmod(0777,'/tmp/test')

    @cijoe = CIJoe.new('/tmp')

    @cijoe.last_build =CIJoe::Build.new_from_hash(
      {
        :project_path => 'path',
        :user         => 'user',
        :project      => 'project',
        :started_at   => Time.now,
        :finished_at  => Time.now,
        :sha          => 'deadbeef',
        :status       => :failed,
        :output       => 'output',
        :pid          => nil
      })

      @cijoe.last_build.commit.raw_commit = "Author: commit author\nDate: now"
  end

  it 'leaves the env intact' do
    ENV['AUTHOR'] = 'foo'
    @cijoe.run_hook("/tmp/test")

    ENV.size.wont_equal 0, 'ENV is empty but should not be'
    ENV['AUTHOR'].must_equal 'foo', 'ENV munged a value'
  end

  it 'works with empty env' do
    ENV["test"] = 'should not be shown'
    output = @cijoe.run_hook("/tmp/test")

    output.must_equal "\ncommit author\n"
  end

  it 'changes the env' do
    ENV['test'] = 'bar'
    output = @cijoe.run_hook("/tmp/test")

    ENV['test'].must_equal 'bar'
  end
end
