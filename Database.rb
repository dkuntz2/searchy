require 'sequel'

Database = "sqlite://searchdb.db"

#configure do 
	DB = Sequel.connect(Database)

	DB.create_table? :pages do
		primary_key :id
		String :url
		String :domain
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
		foreign_key :prime_page_id, :pages
		foreign_key :linked_page_id, :pages
	end


	require "./models/Word.rb"
	require "./models/Page.rb"

#end