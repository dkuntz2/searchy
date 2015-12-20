require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/json'

require_relative 'search.rb'

configure do
	require_relative 'database.rb'
end

get '/' do
	erb :index
end

get '/search' do
	term = params[:terms]
	results = search(term).map do |r|
		{:url => r.url, :score => r.score, :title => r.title}
	end

	json results
end


## Stylesheets!
get '/css/:name.css' do
	content_type 'text/css', :charset => 'utf-8'
	scss :"css/#{params[:name]}"
end


######################
# Page related things
######################
get '/pages' do
	@pages = Page.order(:url).map do |page|
		page
	end

	#json @pages
	erb :pages
end

post '/pages/new' do
	#crawl_ten params[:url]
	Page.find_or_create(:url => params[:url]).crawl
	redirect to('/pages')
end

get '/pages/:id/crawl' do
	p = Page[params[:id].to_i]
	p.crawl unless p.crawled?

	redirect to('/pages')
end

get '/pages/:id/delete' do
	p = Page[params[:id].to_i]
	p.destroy
	redirect to('/pages')
end

######################
# Word related things
######################
get '/words' do
	@words = []
	Word.order(:word).map do |w|
		@words << w.word
	end

	json @words
end
