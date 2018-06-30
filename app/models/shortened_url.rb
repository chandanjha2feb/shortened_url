class ShortenedUrl < ApplicationRecord

	UNIQUE_ID_LENGTH = 6
	validates :original_url, presence: true, on: :create
	validates_format_of :original_url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
	before_create :generate_short_url
	before_create :sanitize

	#Generate a web UNIQUE URL for given Web Address
	def generate_short_url
		url=([*('a'..'z'), *('0'..'9')]).sample(UNIQUE_ID_LENGTH).join
		old_url=ShortenedUrl.where(short_url: url).last
		if old_url.present?
			self.generate_short_url
		else
			self.short_url=url
		end
	end

	#check if any url exist before saving to database
	def find_duplicate
		ShortenedUrl.find_by_sanitize_url(self.sanitize_url)
	end

	def new_url?
		find_duplicate.nil?
	end

	#sanitize the user givenm url
	def sanitize
		self.original_url.strip!
		self.sanitize_url= self.original_url.downcase.gsub(/(https?:\/\/)|(ww\.)/, "")
		self.sanitize_url= "http://#{self.sanitize_url}"
	end
end
