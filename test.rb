require 'test/unit'
require 'nokogiri'
require 'uri'

require_relative 'utils.rb'
require_relative 'database.rb'
require_relative 'search.rb'


class DBTests < Test::Unit::TestCase
	def test_new_page
		page = Page.find_or_create :url => "http://don.kuntz.co"
		unless page.crawled
			page.crawl
		end

		assert_equal("http://don.kuntz.co", page.url)
	end

	def test_nf_word_in_page_has_count
		WordInPage.all.each do |wip|
			#puts "#{wip.word.word} : #{wip.page.url} : #{wip.count}"
		end
	end

	def test_search
		#puts

		# make sure we have a page
		p = Page.find_or_create :url => "http://don.kuntz.co"
		unless p.crawled?
			p.crawl
		end

		terms = ["Don Kuntz", "Computer Science", "Carthage College", "software", "developers", "code"]

		terms.each do |t|
			puts t + ":"
			puts search(t).to_s
		end
	end
end

class StringStripTest < Test::Unit::TestCase
	def test_tokenize
		a = "Hello!!"
		a.tokenize!
		assert_equal("hello", a)
	end

	def test_tokenize_arr
		a = ["~Hello", "", "!!!", "What!", "this", "That!@"]
		a.delete_if do |i|
			i.tokenize!
			i == ""
		end

		assert_equal(["hello", "what", "this", "that"], a)
	end
end

class HTMLTests < Test::Unit::TestCase
	def test_find_links
		html = '<a href="http://don.kuntz.co"></a><a href="http://blog.kuntz.co"></a><a href="http://google.com"></a>'

		page = Nokogiri::HTML(html)
		link_urls = page.css("a").map do |a|
			a["href"]
		end

		assert_equal(['http://don.kuntz.co', 'http://blog.kuntz.co', 'http://google.com'], link_urls)
	end

	def test_correct_links
		# current location
		page_url = "http://blog.kuntz.co"
		hrefs = ['http://don.kuntz.co', '/2014/03/15/deploying-a-sinatra-app-to-heroku.html', 'http://jekyllrb.com', '#something', '?thisAndThat']

		expected = ['http://don.kuntz.co', 'http://blog.kuntz.co/2014/03/15/deploying-a-sinatra-app-to-heroku.html', 'http://jekyllrb.com', page_url]
		expected.sort!

		outcome = hrefs.map do |a|
			if a[0] == '/'
				a = page_url + a
			elsif a[0] == '?' || a[0] == '#'
				a = page_url
			end

			a
		end
		outcome.uniq!.sort!

		assert_equal(expected, outcome)
	end
end
