require 'sequel'

class PageLinks < Sequel::Model
	def prime
		Page.where :id => self.prime_page_id
	end

	def link
		Page.where :id => self.linked_page_id
	end
end