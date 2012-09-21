require "helper"

class TestCIJoeGit < Test::Unit::TestCase
  def setup
    @git = CIJoe::Git.new(temp_repo('testrepo.git'))
  end

  def test_user_and_project
    user, project = @git.user_and_project
    assert_equal 'testrepo.git', user
    assert_equal '.', project
  end

  def test_user_and_project_on_invalid_repo
    @git = CIJoe::Git.new('invalid_repo_path')
    assert_raise CIJoe::Git::InvalidGitRepo do
      @git.user_and_project
    end
  end

  def test_branch_sha
    assert_equal 'b557b867cfc8b86aa5ad73729ffe0017922fbce1', @git.branch_sha('master')
  end

  def test_branch
    assert_equal 'master', @git.branch
  end

  def test_tag
    sha = '018141ee284c47db643e5fd6da9e639f32f891ef'
    tag_name = 'current'
    @git.tag(sha, tag_name)
    tag_sha = `cd #{@git.project_path} && git rev-parse #{tag_name}`.chomp
    assert_equal sha, tag_sha
  end

  def test_tag_overwrite
    tag_name = 'current'
    @git.tag('HEAD~1', tag_name)
    @git.tag('HEAD', tag_name)
    assert_equal @git.rev_parse('HEAD'), @git.tag_sha(tag_name)
  end

  def test_tag_sha
    sha = '018141ee284c47db643e5fd6da9e639f32f891ef'
    tag_name = 'current'
    @git.tag(sha, tag_name)
    assert_equal sha, @git.tag_sha(tag_name)
  end

  def test_note_add
    text = 'note test'
    sha = 'HEAD'
    @git.note(sha, text)
    note_text = `cd #{@git.project_path} && git notes --ref=build show HEAD`
    assert_equal text + "\n", note_text
  end

  def test_note_message
    text = 'note test'
    sha = 'HEAD'
    @git.note(sha, text)
    assert_equal text, @git.note_message(sha)
  end
end
