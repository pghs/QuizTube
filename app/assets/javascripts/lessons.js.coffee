class Quiz
	id: null
	questions: []
	video: null
	current_question: null
	constructor: ->
		@id = $("#lesson_id").val()
		@load_questions()
		# $(".question_marker").on "click", => @load_question()
		$("#add_question a").on "click", => @add_question()
		$("#finish").on "click", => @complete_question()
		# $("#question_input, .answer_field").on "keydown", (e) => @show_next_input($(e.target).attr "id")
		$("#question_input").on "change", (e) => if @current_question then @current_question.save("question":$(e.target).val()) else @questions.push new Question "question":$(e.target).val()
		$(".answer_field").on "change", (e) => @current_question.save_answer($(e.target))
	load_questions: =>
		$.getJSON "/lessons/#{@id}/questions", (data) => 
			console.log data
	add_question: => 
		$("#add_question").hide()
		$("#question_container").fadeIn()
		video.addQuestionClipMarkers()
		@current_question = null
	complete_question: =>
		$("#add_question").fadeIn()
		$("#question_container").hide()	
		@clear_fields()
	clear_fields: => 
		$("#question_input, .answer_field").val("")
		$(".answer_field").removeAttr("answer_id")
	show_next_input: (id) =>
		switch id
			when "question_input" then $("#answer_1").fadeIn()
			when "answer_input_1" then $("#answer_2").fadeIn()
			when "answer_input_2" then $("#answer_3").fadeIn()
			when "answer_input_3" then $("#answer_4").fadeIn()

class Question
	id: null
	text: null
	answers: []
	constructor: (data) ->
		# console.log "New question"
		@save(data)
	save: (data) => 
		console.log data
		question_data = {}
		window.quiz.current_question = @
		data["lesson_id"] = window.quiz.id
		question_data["question"] = data
		# console.log "Save question"
		[submit_url, method] = if @id then ["/questions/" + @id, "PUT"] else ["/questions", "POST"]
		$.ajax
			url: submit_url
			type: method
			data: question_data
			success: (e) => @id = e unless @id
	save_answer: (element) =>
		number = element.attr "number"
		if @answers[number] then @answers[number].save(element) else @answers.push new Answer element, @, number

class Answer
	id: null
	question: null
	text: null
	number: null
	correct: false
	constructor: (element, question, number) ->
		# console.log "New answer"
		@question = question
		@correct = true if number == 0
		@save(element)
	save: (element) => 
		@text = element.val()
		console.log "Save answer"
		[submit_url, method] = if @id then ["/answers/" + @id, "PUT"] else ["/answers", "POST"]
		answer_data = 
			"answer":
				answer: @text
				question_id: @question.id
				correct: @correct
		console.log @
		console.log answer_data
		$.ajax
			url: submit_url
			type: method
			data: answer_data
			success: (e) => @id = e	unless @id


class Video
	questions:null
	active_question_index:0

	ytPlayer: null
	current_timer: null
	video_duration: null

	current_start_marker_time: null
	current_end_marker_time: null

	constructor: (questions)->
		@questions = []
		if questions
			@questions = questions.map (q) -> #maps question array as Question object array
			return new Question(q)

	init: (video_url) ->
		@loadQuestionMarkers()

	loadQuestionMarkers: ->
		$.each @questions, (i, q) =>
			position = (q.clip_end_time/@video_duration)*100
			marker_class = 'unanswered'
			switch q.state
				when -1 then  marker_class = 'wrong'
				when 0 then marker_class = 'unanswered'
				when 1 then marker_class = 'first-correct'
				when 2 then marker_class = 'multi-correct'
				else marker_class = 'unanswered'

			marker = "<div class='q-marker-spacer' style='margin-left:#{position}%;'>
									<div class='q-marker #{marker_class}'>
										<div class='q'>
											img class='small' alt='Trans' src='/assets/trans.png' id='#{i}'/>
										</div></div></div>"
			$('#q-markers').append(marker)

	addQuestionClipMarkers: ->
		current_time = @ytPlayer.getCurrentTime()
		duration = @ytPlayer.duration

		start_pos = 0
		@current_start_marker_time = 0
		if (current_time-20)>0
			@current_start_marker_time = current_time - 20
			start_pos = ((current_time-20)/duration)*100
		start_marker = "<div class='q-marker-spacer' style='margin-left:#{start_pos}%;'>
			<div class='q-marker wrong start'>
			<div class='q'>
			<img class='small' alt='Trans' src='/assets/trans.png'id='start_marker'/>
			</div></div></div>"
		end_pos = 2
		if ((current_time/duration)*100) > 2
			end_pos = (current_time/duration)*100
		@current_end_marker_time = current_time
		end_marker = "<div class='q-marker-spacer' style='margin-left:#{end_pos}%;'>
			<div class='q-marker wrong end'>
			<div class='q'>
			<img class='small' alt='Trans' src='/assets/trans.png'id='end_marker'/>
			</div></div></div>"
		$('#q-markers').append(start_marker)
		$('#q-markers').append(end_marker)

		$( ".q-marker" ).draggable({
			axis: 'x',
			containment: '#progress_bar',
			handle : '.small',
			stop: (event, ui)->
				video.playPreviewClip(ui)
				video.setMarkerBoundaries(ui)
				console.log @current_start_marker_time
				# setTimeout((-> 
				# 	if window.quiz.current_question then window.quiz.current_question.save("clip_start_time": @current_start_marker_time, "clip_end_time": @current_end_marker_time) else window.quiz.questions.push new Question "clip_start_time": @current_start_marker_time, "clip_end_time": @current_end_marker_time),
				# 	1000)			  
			});
		setInterval(=>
		  @setMarkerBoundaries(null)
		, 1000)
    
	playPreviewClip: (ui)->
		marker = ui.helper[0].children[0].children[0].id
		console.log marker
		percent_offset = parseFloat(ui.position.left / $('#progress_bar').width())
		pos = $(ui.helper[0].parentElement).attr('style')
		sub = pos.substr(pos.indexOf(":") + 1, 6)
		ratio = (parseFloat(sub) / 100)
		sec = (ratio + percent_offset) * @ytPlayer.duration
		if marker == 'start_marker'
			console.log marker
			@current_start_marker_time = sec
		else
			console.log marker
			@current_end_marker_time = sec
		@ytPlayer.playVideo()
		@ytPlayer.seekTo(sec - 2)
		clip_interval = setInterval(=>
			current_time = @ytPlayer.getCurrentTime()
			if current_time > sec
				@ytPlayer.pauseVideo()
				clearInterval(clip_interval)
		, 250)

	setMarkerBoundaries: (ui) ->
		console.log ui
		st_x1 = $('#progress_bar').offset().left
		st_y1 = $('#progress_bar').offset().top
		st_x2 = $('.q-marker.end').offset().left
		st_y2 = st_y1

		end_x1 = $('.q-marker.start').offset().left
		end_y1 = st_y1
		end_x2 = st_x1 + $('#progress_bar').width()
		end_y2 = st_y1
		$(".q-marker.start").draggable("option", "containment", [st_x1, st_y1, st_x2-5, st_y2])
		$(".q-marker.end").draggable("option", "containment", [end_x1+5, end_y1, end_x2, end_y2])

$ ->
	window.run = ->
		#if window.question_marker_id>=0 then w = 560 else w = 710
		video.ytPlayer = $('#video_container').youTubeEmbed(
			video: "http://www.youtube.com/watch?v=#{window.media_url}"
			width: 710#w
			progressBar: true
			playerapiid: 'player1'
		)

	window.onYouTubePlayerReady = (playerId) ->
		if video.ytPlayer == null
			setTimeout((-> 
				window.onYouTubePlayerReady(playerId)),
				10)
		else
			#temp call ytembed player ready function
			window.onAfterYouTubePlayerReady(-1)
		null


	if $('#create_quiz').length > 0
		window.quiz = new Quiz
		##Load back end variables
		window.questions = $.parseJSON($("#questions").attr("value"))
		window.media_url = $("#media_url").attr("value")

		window.video = new Video(window.questions)

		window.video.init(window.media_url)
		window.run()
