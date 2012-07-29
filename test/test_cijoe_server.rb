require "helper"
require "rack/test"
require "cijoe/server"

class TestCIJoeServer < Test::Unit::TestCase
  include Rack::Test::Methods

  class ::CIJoe
    # make Build#restore a no-op so we don't overwrite our current/last
    # build attributes set from tests.
    def restore
    end

    # make CIJoe#build! and CIJoe#git_update a no-op so we don't overwrite our local changes
    # or local commits nor should we run tests.
    def build!
    end
  end

  def app
    CIJoe::Server.new
  end

  def test_ping
    last_build = build :worked
    CIJoe.any_instance.stubs(:last_build).returns(last_build)

    get "/ping"
    assert_equal 200, last_response.status
    assert_equal last_build.sha, last_response.body
  end

  def test_ping_building
    current_build = build :building
    CIJoe.any_instance.stubs(:current_build).returns(current_build)

    get "/ping"
    assert_equal 412, last_response.status
    assert_equal "building", last_response.body
  end

  def test_ping_building_with_a_previous_build
    last_build = build :worked
    CIJoe.any_instance.stubs(:last_build).returns(last_build)

    current_build = build :building
    CIJoe.any_instance.stubs(:current_build).returns(current_build)
    CIJoe.any_instance.stubs(:building?).returns(true)

    get "/ping"
    assert_equal 412, last_response.status
    assert_equal "building", last_response.body
  end

  def test_ping_failed
    last_build = build :failed
    CIJoe.any_instance.stubs(:last_build).returns(last_build)

    get "/ping"
    assert_equal 412, last_response.status
    assert_equal last_build.sha, last_response.body
  end

  def test_post_with_json_works
    CIJoe.any_instance.expects(:build)

    post '/', :payload => File.read("#{Dir.pwd}/test/fixtures/payload.json")
    assert_equal 302, last_response.status
  end

  def test_post_does_not_build_on_branch_mismatch
    CIJoe.any_instance.expects(:build).never

    post "/", :payload => {"ref" => "refs/heads/dont_build"}.to_json

    assert_equal 302, last_response.status
  end

  def test_post_builds_specific_branch
    CIJoe.any_instance.expects(:build).with("branchname")

    post "/?branch=branchname", :payload => {"ref" => "refs/heads/master"}.to_json
    assert_equal 302, last_response.status
  end

  def test_post_does_build_on_branch_match
    CIJoe.any_instance.expects(:build)

    post "/", :payload => {"ref" => "refs/heads/master"}.to_json
    assert_equal 302, last_response.status
  end

  def test_post_does_build_when_build_button_is_used
    CIJoe.any_instance.expects(:build)

    post "/", :rebuild => true
    assert_equal 302, last_response.status
  end

  def test_jsonp_should_return_plain_json_without_param
    last_build = build :failed
    CIJoe.any_instance.stubs(:last_build).returns(last_build)

    get "/api/json"
    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response.content_type
  end

  def test_jsonp_should_return_jsonp_with_param
    last_build = build :failed
    CIJoe.any_instance.stubs(:last_build).returns(last_build)

    get "/api/json?jsonp=fooberz"
    assert_equal 200, last_response.status
    assert_equal 'application/json', last_response.content_type
    assert_match /^fooberz\(/, last_response.body
  end

  def test_should_not_barf_when_no_build
  end

  # Create a new, fake build. All we care about is status.

  def build status
    CIJoe::Build.new "path", "user", "project", Time.now, Time.now,
      "deadbeef", status, "output", nil
  end
end
