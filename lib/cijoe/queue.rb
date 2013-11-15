require 'redis'
require 'redis/objects'
require 'redis/list'
require 'uri'

class CIJoe
  # An in memory queue used for maintaining an order list of requested
  # builds.
  class Queue
    # enabled - determines whether builds should be queued or not.
    def initialize(enabled, verbose=false)
      @enabled = enabled
      @verbose = verbose
      if ENV["REDIS_URL"]
        ENV["REDIS_URL"] ||= "redis://localhost:6379/"
        uri = URI.parse(ENV["REDIS_URL"])
        $redis = Redis::Objects.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)
        @queue = Redis::List.new('cijoe:queue')
      else
        @queue = []
      end
      log("Build queueing enabled") if enabled
    end

    # Public: Appends a branch to be built, unless it already exists
    # within the queue.
    #
    # branch - the name of the branch to build or nil if the default
    #         should be built.
    #
    # Returns nothing
    def append_unless_already_exists(branch)
      return unless enabled?
      unless @queue.include? branch
        @queue << branch
        log "#{Time.now.to_i}: Queueing #{branch}"
      end
    end

    # Returns a String of the next branch to build
    def next_branch_to_build
      branch = filtered_queue.shift
      if @queue.delete(branch)
        log "#{Time.now.to_i}: De-queueing #{branch}"
        branch
      else
        nil
      end
    end

    def filtered_queue
      branches_to_consider = (ENV["CIJOE_BRANCHES"] && ENV["CIJOE_BRANCHES"].split(",")).to_a
      branches_to_ignore = (ENV["CIJOE_IGNORE"] && ENV["CIJOE_IGNORE"].split(",")).to_a
      result = @queue.to_a
      unless branches_to_consider.empty?
        result &= branches_to_consider 
      end
      unless branches_to_ignore.empty?
        result -= branches_to_ignore 
      end
      result      
    end

    # Returns true if there are requested builds waiting and false
    # otherwise.
    def waiting?
      if enabled?
        not filtered_queue.empty?
      else
        false
      end
    end

  protected
    def log(msg)
      puts msg if @verbose
    end

    def enabled?
      @enabled
    end
  end
end
