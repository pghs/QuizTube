class Quiz
	id: null
	questions: []
	current_question: null
	constructor: ->
		# $(".question_marker").on "click", => @load_question()
		$("#add_question a").on "click", => @add_question()
		$("#finish").on "click", => @complete_question()
		$("#question_input, .answer_field").on "keydown", (e) => @show_next_input($(e.target).attr "id")
		$("#question_input").on "change", (e) => if @current_question then @current_question.save() else @questions.push new Question $(e.target)
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
		@text = element.val()
		@save()
	save: => 
		window.quiz.current_question = @
		# console.log "Save question"
	save_answer: (element) =>
		number = element.attr "number"
		if @answers[number] then @answers[number].save() else @answers.push new Answer element

class Answer
	id: null
	text: null
	number: null
	constructor: (element) ->
		# console.log "New answer"
		@text = element.val()
		@save()
	save: => 
		# console.log "Save answer"
		@id = 37


$ -> window.quiz = new Quiz