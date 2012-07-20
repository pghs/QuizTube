class StudyeggsController < ApplicationController
	def index
		@featured_lessons = []
		@latest_lessons = []
		@lessons = Lesson.all
	end
end
