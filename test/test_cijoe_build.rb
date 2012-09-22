require 'helper'

class TestCIJoeBuild < Test::Unit::TestCase

  def setup
    @time_now =  Time.utc(2007,11,1,15,25)
    @build = CIJoe::Build.new_from_hash(
      {project_path: 'path',
       user:         'user',
       project:      'project',
       started_at:   @time_now,
       sha:          'deadbeef',
       status:       :success,
       output:       'output',
       pid:          nil
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
    yaml = "---\n- user\n- project\n- 2007-11-01 15:25:00.000000000 Z\n- \n- deadbeef\n- :building\n- output\n- \n- \n"
    assert_equal yaml, @build.dump
  end
end
