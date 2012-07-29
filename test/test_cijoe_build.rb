require 'helper'

class TestCIJoeBuild < Test::Unit::TestCase
  def test_new_from_hash
    build = CIJoe::Build.new_from_hash :sha => 'deadbeef'
    assert_equal'deadbeef', build.sha
  end

  def test_new_from_hash_fails_on_extra_args
    assert_raise RuntimeError, ArgumentError do
      build = CIJoe::Build.new_from_hash :illegal => 'deadbeef'
    end
  end
end
