class ShortenedUrlsController < ApplicationController
	before_action :find_url, :only => ['show', 'shortened']
	skip_before_action :verify_authenticity_token

	def index
		@url = ShortenedUrl.new
	end

	def show
		@url.sanitize_url
	end

	def create
		@url = ShortenedUrl.new
		@url.original_url = params[:original_url]
		@url.sanitize_url
		if @url.new_url?
			if @url.save
				redirect_to shortened_path(@url.short_url)
			else
				flash[:error]="CHeck the error"
				render 'index'
			end
		else
			flash[:error]= "This URL already exist"
			redirect_to shortened_path(@url.find_duplicate.short_url)
		end
	end

	def shortened
		@url = ShortenedUrl.find_by_short_url(params[:short_url])
		host= request.host_with_port
		@original_url = @url.sanitize_url
		@short_url= host + '/' +@url.short_url
	end

	def fetch_original
		fetch_url= ShortenedUrl.find_by_short_url(params[:short_url])
		redirect_to fetch_url.sanitize_url
	end

	private

	def find_url
		@url = ShortenedUrl.find_by_short_url(params[:short_url])
	end

	def url_params
		params.require(:url).permit(:original_url)
	end
end
