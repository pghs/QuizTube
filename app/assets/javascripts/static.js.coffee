# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ -> 
	window.resizeContents = ->
		footer = $('#footer')
		contents = $('#main')
		header = $('#header')

		footerY = footer.height()
		contentsY = contents.height()
		headerY = header.height()
		viewportY = $(window).height()

		difference = viewportY - footerY - headerY - 22;
		newContentsY = difference;
		contents.css('minHeight', newContentsY+'px')

		q = $('#questioner')
		if q.length > 0
			offset_top = ($(document).height() - (q.offset().top + q.height())) / 2 - 14
			offset_top = 4 if offset_top < 4
			$("#content").css('paddingTop', offset_top)
	window.onresize = window.resizeContents
	window.resizeContents()