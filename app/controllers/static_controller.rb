class StaticController < ApplicationController
	def home
		redirect_to "/lessons" if current_user
	end
end
