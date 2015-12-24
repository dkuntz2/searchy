require 'sinatra'
require 'sinatra/sequel'
require 'sinatra/json'
require 'sass'

require_relative 'search.rb'

configure do
	require_relative 'database.rb'
end

get '/' do
	erb :index
end

get '/search' do
	term = params[:terms]
	json search(term).map(&:to_h).to_a
end

get '/css/:name.css' do
	content_type 'text/css', :charset => 'utf-8'
	scss :"css/#{params[:name]}"
end

get '/pages' do
	@pages = Page.order(:url)
	erb :pages
end

post '/pages/new' do
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

get '/words' do
	@words = Word.order(:word).map(&:word)
	json @words
end
