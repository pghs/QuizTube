# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Reviewer
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
                      <img class='small' alt='Trans' src='/assets/trans.png' id='#{i}'/>
                </div></div></div>"
      $('#q-markers').append(marker)

  addQuestionClipMarkers: ->
    current_time = @ytPlayer.getCurrentTime()
    duration = @ytPlayer.duration
    position1 = (current_time/duration)*100
    @current_end_marker_time = current_time
    marker1 = "<div class='q-marker-spacer' style='margin-left:#{position1}%;'>
                  <div class='q-marker wrong'>
                    <div class='q'>
                      <img class='small' alt='Trans' src='/assets/trans.png'id='end_marker'/>
                </div></div></div>"
    position2 = 0
    @current_start_marker_time = 0
    if (current_time-20)>0
      @current_start_marker_time = current_time - 20
      position2 = ((current_time-20)/duration)*100
    marker2 = "<div class='q-marker-spacer' style='margin-left:#{position2}%;'>
                  <div class='q-marker wrong'>
                    <div class='q'>
                      <img class='small' alt='Trans' src='/assets/trans.png'id='start_marker'/>
                </div></div></div>"
    $('#q-markers').append(marker1)
    $('#q-markers').append(marker2)
    $( ".q-marker" ).draggable({
      axis: 'x',
      containment: '#progress_bar',
      handle : '.small',
      stop: (event, ui)->
        reviewer.playPreviewClip(ui)
      });

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

$ ->
  window.run = ->
    #if window.question_marker_id>=0 then w = 560 else w = 710
    
    reviewer.ytPlayer = $('#video_container').youTubeEmbed(
      video: "http://www.youtube.com/watch?v=#{window.media_url}"
      width: 710#w
      progressBar: true
      playerapiid: 'player1'
    )

  window.onYouTubePlayerReady = (playerId) ->
    if reviewer.ytPlayer == null
      setTimeout((-> 
        window.onYouTubePlayerReady(playerId)),
        10)
    else
      #temp call ytembed player ready function
      window.onAfterYouTubePlayerReady(-1)
    null

  window.resizeContents = ->
    footer = $('#footer')
    contents = $('#main')
    header = $('#header')
    console.log contents

    footerY = footer.height()
    contentsY = contents.height()
    headerY = header.height()
    viewportY = $(window).height()

    difference = viewportY - footerY - headerY - 22;
    newContentsY = difference;
    contents.css('minHeight', newContentsY+'px')

  if $('#create_quiz').length > 0
    ##Load back end variables
    window.questions = $.parseJSON($("#questions").attr("value"))
    window.media_url = $("#media_url").attr("value")

    window.reviewer = new Reviewer(window.questions)
    
    window.reviewer.init(window.media_url)
    window.run()