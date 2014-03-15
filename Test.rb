require "test/unit"

require_relative 'utils.rb'
require_relative "Database.rb"


class DBTests < Test::Unit::TestCase
	def test_new_page
		page = Page.find_or_create :url => "http://don.kuntz.co"
		assert_equal("http://don.kuntz.co", page.url)
	end

	def test_nf_word_in_page_has_count
		WordInPage.all.each do |wip|
			#puts "#{wip.word.word} : #{wip.page.url} : #{wip.count}"
		end
	end

	def test_search
		puts
		
		# make sure we have a page
		Page.find_or_create :url => "http://don.kuntz.co"

		terms = ["Don Kuntz", "Computer Science", "Carthage College", "software", "developers", "code"]

		terms.each do |t|
			keys = t.split
			keys.delete_if do |k|
				k.tokenize!
				k == ""
			end

			scores = {}
			Page.all.each do |page|
				score = 0
				keys.each do |term|
					#puts "#{page.url} : #{term} : #{page.has_word term}"

					#puts "page.has_word(term) = #{page.has_word term}"
					unless page.has_word term
						next
					end

					term_freq = page.get_word_in_page(term).count
					idf = Word.where(:word => term).first.inverse_document_frequency

					#puts "\nterm_freq: #{term_freq}"
					#puts "idf: #{idf}"
					score += term_freq * idf
				end
				scores[page.url] = score
			end

			scores.each do |k, v|
				puts "#{t} : #{v} : #{k}"
			end
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
