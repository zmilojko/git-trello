#!/usr/bin/ruby

#This is gem, no need to require rubygems
#require 'rubygems'
require 'json'
require 'grit'
require_relative 'git-trello/trello-http'


class GitHook
  def initialize(config)
	@api_key = config[:api_key]
	@oauth_token = config[:oauth_token]
	@repodir = Dir.pwd
	@board_id = config[:board_id]
	@list_id_in_progress = config[:list_id_in_progress]
	@list_id_done = config[:list_id_done]
	@commit_url_prefix = config[:commit_url_prefix]
	
	@http = Trello::HTTP.new(@oauth_token, @api_key)
	@repo = Grit::Repo.new(@repodir)
  end
  def test
    puts 'git-trello post receive hook trigered just fine' 
  end
  def post_receive
	while msg = gets
	  puts msg.inspect
	
	  #get the data out of the input
	  old_sha, new_sha, ref = msg.split(' ', 3)
	  
	  # If post-receive is given a block, execute it 
	  # and pass everything you have to pass
	  yield old_sha, new_sha, ref, @repodir, @http if block_given?	  	  

	  #get the commit out of the new_sha
	  commit = @repo.commit(new_sha)

	  #Following requries quite a bit of testing in case of merging
      until commit.nil? || commit.sha == old_sha
		  # Figure out the card short id
		  match = commit.message.match(/((case|card|close|fix)e?s? \D?([0-9]+))/i)
		  next unless match and match[3].to_i > 0

		  puts "Trello: Commenting on the card ##{match[3].to_i}"

		  results = @http.get_card(@board_id, match[3].to_i)
		  unless results
			puts "Trello: Cannot find card matching ID #{match[3]}"
			next
		  end
		  results = JSON.parse(results)

		  # Determine the action to take
		  target_list_id = ""
		  target_list_id = case match[2].downcase
			when "case", "card" then @list_id_in_progress
			when "close", "fix" then @list_id_done
		  end

		  puts "Trello: Moving card ##{match[3].to_i} to list #{target_list_id}"

		  # Add the commit comment
		  message = "#{commit.author.name}:\n#{commit.message}"
		  message << "\n\n#{@commit_url_prefix}#{new_sha}" unless @commit_url_prefix.nil?
		  message.gsub!(match[1], "")
		  message.gsub!(/\(\)$/, "")
		  message.gsub!(/Signed-off-by: (.*) <(.*)>/,"")
		  @http.add_comment(results["id"], message)

		  unless target_list_id == ""
			to_update = {}
			unless results["idList"] == target_list_id
			  to_update[:idList] = target_list_id
			  @http.update_card(results["id"], to_update)
			end
		  end
	  return if commit.parents.nil? || commit.parents.empty? 
	  puts "now checking parents"
	  commit = commit.parents[0] 
	  end		  
      ""
	end
  end
end

