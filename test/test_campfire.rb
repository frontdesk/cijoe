require "helper"
require "cijoe"
require "fakefs/safe"

def setup_git_info(options = {})
  @tmp_dirs ||= []
  @tmp_dirs += [options[:tmp_dir]]
  create_tmpdir!(options[:tmp_dir])
  dir = options[:tmp_dir] || tmp_dir
  `cd #{dir} && git init`
  options[:config].each do |key, value|
    `cd #{dir} && git config --add #{key} "#{value}"`
  end
end

def teardown_git_info
  remove_tmpdir!
  @tmp_dirs.each do |dir|
    remove_tmpdir!(dir)
  end
end

def remove_tmpdir!(passed_dir = nil)
  FileUtils.rm_rf(passed_dir || tmp_dir)
end

def create_tmpdir!(passed_dir = nil)
  FileUtils.mkdir_p(passed_dir || tmp_dir)
end


def tmp_dir
  TMP_DIR
end

class TestCampfire < MiniTest::Unit::TestCase

  def teardown
    teardown_git_info
  end

  def test_campfire_pulls_campfire_config_from_git_config
    setup_git_info(:config => {"campfire.subdomain" => "github", "remote.origin.url" => "https://github.com/defunkt/cijoe.git"})
    cf = CIJoe::Campfire.new(tmp_dir)
    assert_equal "github", cf.campfire_config[:subdomain]
  end

  def test_campfire_pulls_campfire_config_from_its_own_git_config
    setup_git_info(:config => {"campfire.subdomain" => "github"})
    setup_git_info(:config => {"campfire.subdomain" => "37signals"}, :tmp_dir => "/tmp/cijoe_test_37signals")
    cf1 = CIJoe::Campfire.new(tmp_dir)
    cf2 = CIJoe::Campfire.new("/tmp/cijoe_test_37signals")
    assert_equal "github", cf1.campfire_config[:subdomain]
    assert_equal "37signals", cf2.campfire_config[:subdomain]
  end

end
