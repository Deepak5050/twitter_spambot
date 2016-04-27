require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
	attr_reader :client

	def initialize
		puts "initializing.."
		@client = JumpstartAuth.twitter
		@bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
	end

	def tweet(message)
		p	message.size <= 140 ? @client.update(message) : "message should be between 1 to 140 chars"
	end

	def followers_list
		screen_names = []
 	 	@client.followers.each do |follower|
 	 		screen_names << @client.user(follower).screen_name
 	 	end
 	 	screen_names
	end

	def spam_my_followers(message)
		list = followers_list
		list.each { |follower| dm(follower, message) }
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message"
		puts "message"
		message = "d @#{target} #{message}"
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		
		if screen_names.include? target 
			tweet(message)
		else
			puts  "#{target} is not your follower. You can't send direct message to #{target}"
		end
	end

  def everyones_last_tweet
    friends = @client.friends
    friends = friends.sort_by { |friend| friend.screen_name.downcase }
    friends.each do |friend|
      timestamp = friend.status.created_at
      timestamp.strftime("%A, %b %d")
      puts "#{friend.screen_name} said this on #{timestamp}..."
      puts friend.status.text
    end
  end

  def shorten(original_url)
  	 	puts "Shortening this URL: #{original_url}"
  	 	return @bitly.shorten(original_url).short_url
  end

	def run 
		puts "Welcome to the JSL Twitter Client!"
	  command = ''
	  while command != "q"
	    printf "enter command: "
	    input = gets.chomp
	    parts = input.split(' ')
	    command = parts[0]
	    case command
	    when 'q' then puts "Goodbye!"
	    when 't' then tweet(parts[1..-1].join(' '))
	    when 'dm' then dm(parts[1], parts[2..-1].join(' '))
	    when 'spam' then spam_my_followers(parts[1..-1].join(' '))
	    when 'elt' then everyones_last_tweet
	    when 'turl' then tweet(parts[1..-2].join(' ') + " " + shorten(parts[-1]))
	    else
	    	puts "Sorry, I don't know how to #{command}"
	    end
	  end
	end
end

blogger = MicroBlogger.new
blogger.run