require "helper"

class TestCIJoeGit < Test::Unit::TestCase
  def setup
    @git = CIJoe::Git.new(temp_repo('testrepo.git'))
  end

  def test_branch_sha
    assert_equal 'b557b867cfc8b86aa5ad73729ffe0017922fbce1', @git.branch_sha('master')
  end

  def test_branch
    assert_equal 'master', @git.branch
  end

end
