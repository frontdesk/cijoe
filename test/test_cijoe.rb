require 'helper'

class TestCIJoe < Test::Unit::TestCase
  def setup
    @cijoe = CIJoe.new(temp_repo('testrepo.git'))

    @build = CIJoe::Build.new(
      {
       :project_path => 'path',
       :user         => 'user',
       :project      => 'project',
       :started_at   => Time.now,
       :sha          => 'HEAD',
       :status       => :success,
       :output       => 'output',
       :pid          => nil
    })

  end

  def test_write_build
    assert_nothing_raised do
      @cijoe.write_build('current', @build)
    end
  end

  def test_non_existing_read_build
    assert_equal nil, @cijoe.read_build('current')
  end

  def test_read_build
    @cijoe.write_build('current', @build)
    assert_nothing_raised do
      @cijoe.read_build('current')
    end
  end
end
