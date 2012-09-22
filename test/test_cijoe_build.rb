require 'helper'

class TestCIJoeBuild < Test::Unit::TestCase

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
    assert_raise RuntimeError, ArgumentError do
      build = CIJoe::Build.new_from_hash :illegal => 'deadbeef'
    end
  end

  def test_dump
    json = "[\n  \"user\",\n  \"project\",\n  \"Thu Nov 01 15:25:00 UTC 2007\",\n  null,\n  \"deadbeef\",\n  \"building\",\n  \"output\",\n  null,\n  null\n]"
    assert_equal json, @build.dump
  end

  def test_restore
    json = @build.dump
    parsed = CIJoe::Build.parse(json, 'path')
    assert_equal parsed.started_at, @build.started_at
  end
end
