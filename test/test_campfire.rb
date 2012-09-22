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

describe CIJoe::Campfire do

  def teardown
    teardown_git_info
  end

  it 'pulls config from git config' do
    setup_git_info(:config => {"campfire.subdomain" => "github", "remote.origin.url" => "https://github.com/defunkt/cijoe.git"})
    cf = CIJoe::Campfire.new(tmp_dir)

    cf.campfire_config[:subdomain].must_equal 'github'
  end

  it 'pulls confgit from its own gitconfig' do
    setup_git_info(:config => {"campfire.subdomain" => "github"})
    setup_git_info(:config => {"campfire.subdomain" => "37signals"}, :tmp_dir => "/tmp/cijoe_test_37signals")
    cf1 = CIJoe::Campfire.new(tmp_dir)
    cf2 = CIJoe::Campfire.new("/tmp/cijoe_test_37signals")

    cf1.campfire_config[:subdomain].must_equal 'github'
    cf2.campfire_config[:subdomain].must_equal '37signals'
  end
end
