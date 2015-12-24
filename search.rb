
require_relative 'database.rb'
require_relative 'utils.rb'

class Result < Struct.new(:url, :score, :title)
end

def search(search_term)
	terms = search_term.split.map(&:tokenize!)
	terms.reject!(&:empty?)

	results = Page.all.map do |page|
		score = terms.reduce(0) do |sum, term|
			next sum unless page.has_word(term)

			term_freq = page.get_word_in_page(term).count
			inverse_doc_freq = Word.where(:word => term).first.inverse_document_frequency

			sum += term_freq * inverse_doc_freq
		end

		Result.new(page.url, score, (page.title.empty? ? page.title : page.url))
	end

	results.reject! { |result| result.score == 0 }
	results.sort_by! { |result| [-result.score, result.url, result.title] }
end
