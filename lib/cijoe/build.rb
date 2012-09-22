require 'json'

class CIJoe
  class Build < Struct.new(:project_path, :user, :project, :started_at, :finished_at, :sha, :status, :output, :pid, :branch)

    def initialize(*args)
      super
      self.started_at ||= Time.now
    end

    def self.new_from_hash(hash)
      (hash.keys - Build.members.map{|member| member.to_sym}).tap do |extra_arguments|
        if extra_arguments.any?
          raise ArgumentError.new("invalid argument #{extra_arguments.join(' ')}")
        end
      end

      new( *hash.values_at(*Build.members.map {|member| member.to_sym}))
    end

    def status
      return super if started_at && finished_at
      :building
    end

    def failed?
      status == :failed
    end

    def worked?
      status == :worked
    end

    def building?
      status == :building
    end

    def duration
      return if building?
      finished_at - started_at
    end

    def short_sha
      if sha
        sha[0,7]
      else
        "<unknown>"
      end
    end

    def to_map
      map = Hash.new
      self.members.each { |m| map[m] = self[m] }
      map
    end

#    def to_json(*a)
#      to_map.to_json(*a)
#    end

    def clean_output
      output.gsub(/\e\[.+?m/, '').strip
    end

    def env_output
      out = clean_output
      out.size > 100_000 ? out[-100_000,100_000] : out
    end

    def commit
      return if sha.nil?
      @commit ||= Commit.new(sha, user, project, project_path)
    end

    def dump
      config = [user, project, started_at, finished_at, sha, status, output, pid, branch]
      JSON.pretty_generate(config)
    end

    def self.parse(data, project_path)
      config = JSON.load(data).unshift(project_path)
      new(*config).tap do |build|
        build.started_at = Time.parse(build.started_at) if build.started_at
        build.finished_at = Time.parse(build.finished_at) if build.finished_at
      end
    end
  end
end
