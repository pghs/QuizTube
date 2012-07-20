class Quiz
	id: null
	questions: []
	current_question: null
	constructor: ->
		@id = $("#lesson_id").val()
		# $(".question_marker").on "click", => @load_question()
		$("#add_question a").on "click", => @add_question()
		$("#finish").on "click", => @complete_question()
		$("#question_input, .answer_field").on "keydown", (e) => @show_next_input($(e.target).attr "id")
		$("#question_input").on "change", (e) => if @current_question then @current_question.save($(e.target)) else @questions.push new Question $(e.target)
		$(".answer_field").on "change", (e) => @current_question.save_answer($(e.target))
	add_question: => 
		$("#add_question").hide()
		$("#question_container").fadeIn()
		@current_question = null
	complete_question: =>
		$("#add_question").fadeIn()
		$("#question_container, .answer").hide()	
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
	constructor: (element) ->
		# console.log "New question"
		@save(element)
	save: (element) => 
		# console.log "Save question"
		@text = element.val()
		window.quiz.current_question = @
		[submit_url, method] = if @id then ["/questions/" + @id, "PUT"] else ["/questions", "POST"]
		question_data = 
			"question":
				question: @text
				lesson_id: window.quiz.id
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


$ -> window.quiz = new Quiz