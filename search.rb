require 'set'

require_relative 'Database.rb'
require_relative 'utils.rb'

class Result < Struct.new :url, :score
end

def search searchterm
	terms = searchterm.split
	terms.delete_if do |k|
		k.tokenize!
		k == ""
	end

	scores = {}
	Page.all.each do |page|
		score = 0
		terms.each do |term|
			unless page.has_word term
				next
			end

			term_freq = page.get_word_in_page(term).count
			inverse_doc_freq = Word.where(:word => term).first.inverse_document_frequency

			score += term_freq * inverse_doc_freq
		end

		scores[page.url] = score
	end

	scores_arr = scores.collect { |k, v| Result.new(k, v) }
	scores_arr.sort_by { |s| [-s.score, s.url] }

	scores_arr.tap {|sc| sc.delete_if {|s| s.score == 0 } }
end

def crawl_ten page_url
	page = crawl_page page_url

	pages_to_crawl = []

	PageLinks.where(:prime_id => page.id).each do |pl|
		unless page.crawled?
			pages_to_crawl << Page[pl.linked_id]
			pages_to_crawl.uniq!

			if pages_to_crawl.length > 10
				break
			end
		end
	end


	(1..10).each do |i|
		p = crawl_page pages_to_crawl[i]
		if pages_to_crawl.length <= 10
			PageLinks.where(:prime_id => page.id).each do |pl|
				unless page.crawled?
					pages_to_crawl << Page[pl.linked_id]
					pages_to_crawl.uniq!

					if pages_to_crawl.length > 10
						break
					end
				end
			end
		end
	end
end

def crawl_page page_url
	puts "crawling #{page_url}"

	pages_to_crawl = []
	page = Page.find_or_create :url => page_url
	unless page.crawled?
		page.crawl
	end

	page
end