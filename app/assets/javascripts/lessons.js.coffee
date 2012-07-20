class Builder
	book_id: null
	constructor: -> @initializeListeners()
	initializeListeners: =>
		$(".status.inactive").on "click", (e) => @updateStatus(e.srcElement, 1, @redirectToChapter)
		$(".status.publish").on "click", (e) => @updateStatus(e.srcElement, 3, @updatePublishButton)
		$("#add_chapters_action").on "click", (e) => 
			e.preventDefault()
			@addChapters($("#book_name").attr "value")
	addChapters: (book_id) =>
		data = "book_id": book_id
		$.ajax
			url: "/books/get_next_chapter_number"
			type: "POST"
			data: data	
			success: (number) =>
				for chapter in $("#add_chapters_area").val().split("\n")
					[name, url] = chapter.split("|")
					data = 
						"book_id": book_id
						"chapter": 	
							"number": number
							"name": $.trim(name)
							"media_url": $.trim(url)
					$.ajax
						url: "/chapters"
						type: "POST"
						data: data
						success: () => $("#add_chapters_area").val("")
					number += 1
	updateStatus: (element, status, callback) =>
		data = 
			"id": $(element).attr("chapter_id")
			"status": status
			"type": "START"
		$.ajax
			url: "/chapters/update_status"
			type: "POST"
			data: data	
			success: () => callback(element)
	redirectToChapter: (element) => window.location = "/chapters/#{$(element).attr("chapter_id")}"
	updatePublishButton: (element) => $(element).removeClass("publish").addClass("published").text("Published")

$ -> window.status = new Builder