require 'sequel'
require 'uri'
require 'open-uri'
require 'sanitize'

require_relative '../utils.rb'

class Page < Sequel::Model

	def self.crawl_uncrawled
		Page.where(:crawled => false).each do |p|
			puts "Crawling #{p.url}"
			p.crawl
		end
	end

	def self.crawl_all_forever
		i = 1
		while Page.where(:crawled => false).count != 0
			puts
			puts
			puts
			puts "Starting crawl iteration #{i.to_s}"
			Page.where(:crawled => false).each do |p|
				puts "Crawling #{p.url}"
				p.crawl
			end
			i += 1
		end
	end

	def self.crawl_domain domain
		puts "Finding, and potentially crawling, root: #{domain}"
		root = Page.find_or_create :url => domain
		root.crawl unless root.crawled?

		Page.where(:crawled => false).each do |p|
			if p.url[0, domain.length] == domain
				puts "Crawling #{p.url}"
				p.crawl
			end
		end
	end



	def before_create
		self.crawled = false
		self.title = ""
	end

	def before_destroy
		# clear out relations in other tables.
		WordInPage.where(:page_id => self.id).each { |wip| wip.destroy }
		PageLinks.where(:prime_id => self.id).each { |pl| pl.destroy }
		PageLinks.where(:linked_id => self.id).each { |pl| pl.destroy }
	end

	def crawled?
		self.crawled
	end

	def crawl
		# clear out relations in other tables.
		WordInPage.where(:page_id => self.id).each { |wip| wip.destroy }
		PageLinks.where(:prime_id => self.id).each { |pl| pl.destroy }

		# get some fun stuff...
		uri = URI(self.url)
		self.domain = uri.host

		# grab the contents of the page
		html = ""
		cleaned = ""
		begin
			html = open(uri).read()
			cleaned = Sanitize.clean(html)
		rescue
			self.destroy
			return nil
		end

		##
		# Word stuffs
		
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


		## 
		# links and such
		noko = Nokogiri::HTML(html)
		title_tag = noko.css("title")[0]
		if title_tag != nil
			self.title = noko.css("title")[0].text
		else
			self.title = ""
		end

		links = noko.css("a").each do |a|
			# is this a real page?
			link = a["href"]
			if link.nil? || link.length == 0
				next
			end

			if link[0] != "/" && link[0, ("http".length)] != "http"
				next
			end
			if link[0] == "/"
				if link.length != 1 && link[1] == "/"
					link = uri.scheme + link
				else
					link = uri.scheme + '://' + uri.host + link
				end
			end

			if link[-1] == "/"
				link.slice! -1
			end

			linked = Page.find_or_create :url => link
			PageLinks.find_or_create :prime_id => self.id, :linked_id => linked.id
		end


		self.crawled = true
		self.last_crawl = Time.now.to_i
		self.save
	end

	def has_word word
		wip = self.get_word_in_page word
		return !wip.nil?
	end

	def get_word_in_page word
		# does the word exist in the DB
		w = Word.where(:word => word)
		if w.count == 0
			return nil
		end

		wip = WordInPage.where(:word_id => w.first.id, :page_id => self.id)
		return wip.first
	end
end