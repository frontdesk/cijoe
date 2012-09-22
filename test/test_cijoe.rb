require 'helper'

class TestCIJoe < MiniTest::Unit::TestCase
  def setup
    @path = setup_test_repo
    @cijoe = CIJoe.new(@path)

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

  def teardown
    destroy_repo(@path)
  end

  def test_write_build
    assert @cijoe.write_build('current', @build).inspect
  end

  def test_non_existing_read_build
    assert_nil @cijoe.read_build('current')
  end

  def test_read_build
    @cijoe.write_build('current', @build)
    assert @cijoe.read_build('current')
  end
end
