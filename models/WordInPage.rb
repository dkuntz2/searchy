require 'sequel'

class WordInPage < Sequel::Model
	def before_create
		self.count = 0
	end

	def word
		return Word[self.word_id]
	end

	def page
		return Page[self.page_id]
	end
end