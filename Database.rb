require 'sequel'

dburl = ENV['DATABASE_URL'] || "sqlite://searchdb.db"
DB = Sequel.connect(dburl)

DB.create_table? :pages do
	primary_key :id
	String :url
	String :domain
	String :title
	Boolean :crawled
	Bignum :last_crawl
end

DB.create_table? :words do
	primary_key :id
	String :word
end

DB.create_table? :word_in_pages do
	primary_key :id
	foreign_key :word_id, :words
	foreign_key :page_id, :pages
	Integer :count
end

DB.create_table? :page_links do
	primary_key :id
	foreign_key :prime_id, :pages
	foreign_key :linked_id, :pages
end


require "./models/Word.rb"
require "./models/Page.rb"
require "./models/WordInPage.rb"
require "./models/PageLinks.rb"

class PageLinks < Sequel::Model
end
