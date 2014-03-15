require 'sequel'
require 'uri'
require 'net/http'
require 'sanitize'
require_relative 'utils.rb'

class Page < Sequel::Model
	def after_create
		uri = URI(self.url)
		self.domain = uri.host

		# grab the contents of the page
		html = Net::HTTP.get(uri)
		cleaned = Sanitize.clean(html)
		
		# turn big string of words into array of words
		words = cleaned.split
		words.delete_if do |w|
			w.tokenize!
			w == ""
		end

		# parse the content (AKA: put words in DB)
		words.each do |word|
			w = Word.find_or_create :word => word
			w.add_page self
		end
	end

	def has_word word
		wip = self.get_word_in_page word
		return wip != nil
	end

	def get_word_in_page word
		# does the word exist in the DB
		w = Word.where(:word => word)
		if w.count == 0
			return false
		end

		wip = WordInPage.where(:word_id => w.first.id, :page_id => self.id)
		return wip.first
	end
end