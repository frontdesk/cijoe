require 'rubygems'
require 'minitest/autorun'
require 'mocha'

ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cijoe'

CIJoe::Server.set :project_path, "."
CIJoe::Server.set :environment,  "test"

TMP_DIR = '/tmp/cijoe_test'

TEST_DIR = File.dirname(File.expand_path(__FILE__))

class MiniTest::Unit::TestCase
  private

  def temp_repo(repo)
    dir = Dir.mktmpdir 'dir'
    repo_dir = File.join(TEST_DIR, (File.join('fixtures', repo, '.')))
    `git clone #{repo_dir} #{dir}`
    dir
  end

  def destroy_repo(repo)
    FileUtils.remove_entry_secure repo
  end

end
