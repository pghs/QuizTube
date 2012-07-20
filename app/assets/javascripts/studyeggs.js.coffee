# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  window.run = ->
    #if window.question_marker_id>=0 then w = 560 else w = 710
    
    $('#video_container').youTubeEmbed(
      video: "#{window.media_url}"
      width: 560#w
      progressBar: true
      playerapiid: 'player1'
    )

  window.onYouTubePlayerReady = (playerId) ->
    if window.ytEmbed == null
      console.log 'What?'
      setTimeout((-> 
        window.onYouTubePlayerReady(playerId)),
        10)
    else
      console.log 'WHAT!!!'
      #temp call ytembed player ready function
      window.onAfterYouTubePlayerReady(-1)
    null
  window.media_url = $("#media_url").attr("value")
  window.run()