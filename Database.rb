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


	require_relative "Word.rb"
	require_relative "Page.rb"

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
#end