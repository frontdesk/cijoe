require "helper"
require "cijoe"
require "fakefs/safe"

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
