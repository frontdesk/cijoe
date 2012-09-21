require 'helper'

class TestCIJoeBuild < MiniTest::Unit::TestCase

  def setup
    @time_now =  Time.utc(2007,11,1,15,25)
    @build = CIJoe::Build.new_from_hash(
      {
       :project_path => 'path',
       :user         => 'user',
       :project      => 'project',
       :started_at   =>  @time_now,
       :sha          => 'deadbeef',
       :status       => :success,
       :output       => 'output',
       :pid          => nil
    })
  end

  def test_new_from_hash
    build = CIJoe::Build.new_from_hash :sha => 'deadbeef'
    assert_equal'deadbeef', build.sha
  end

  def test_new_from_hash_fails_on_extra_args
    assert_raises RuntimeError, ArgumentError do
      build = CIJoe::Build.new_from_hash :illegal => 'deadbeef'
    end
  end

  def test_dump_restore
    json = @build.dump
    parsed = CIJoe::Build.parse(json, 'path')
    assert_equal @build.started_at, parsed.started_at
    assert_equal @build.sha, parsed.sha
  end
end
