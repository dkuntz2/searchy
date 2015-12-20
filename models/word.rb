require 'sequel'

class Word < Sequel::Model
	def add_page(page)
		wip = WordInPage.find_or_create(:word_id => self.id, :page_id => page.id)
		wip.count = wip.count + 1
		wip.save
	end

	def inverse_document_frequency
		num_pages = Page.where(:crawled => true).count
		num_pages_with_word = WordInPage.where(:word_id => self.id).count

		1 + Math.log(num_pages.to_f / (1 + num_pages_with_word).to_f)
	end
end
