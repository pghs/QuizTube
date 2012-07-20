class ytEmbed
  video: null
  width: 640
  progressBar: true
  atts:
    id: "ytPlayer"
  allowScriptAccess: "always"
  wmode: "transparent"
  version: null
  enablejsapi: null
  playerapiid: null

  elements:
    originalDIV : null
    container : null
    control   : null
    player    : null
    progress  : null
    elapsed   : null

  videoID:null
  safeID:null
  ratio:null
  height:null
  duration:null

  constructor: (origDiv, options) ->
    console.log 'YOUrE IN!'
    ##Sets class variables based on passed options
    @video = options.video if options.video
    @width = options.width if options.width
    @progressBar = options.progressBar if options.progressBar
    @atts = options.atts if options.atts
    @allowScriptAccess = options.allowScriptAccess if options.allowScriptAccess
    @wmode = options.wmode if options.wmode
    @version = options.version if options.version
    @enablejsapi = options.enablejsapi if options.enablejsapi
    @playerapiid = options.playerapiid if options.playerapiid
    @elements.originalDIV = origDiv

    try
      @videoID = @video.match(/v=(.{11})/)[1]
      @safeID = @videoID.replace(/[^a-z0-9]/ig,'')
    catch e
      return @elements.originalDIV
    
    @init()


  init: ->
    youtubeAPI = "http://gdata.youtube.com/feeds/api/videos/#{@videoID}?v=2&alt=jsonc"

    $.get youtubeAPI, null, ((response) =>
      data = response.data

      console.log data
      
      return @elements.originalDIV  if not data or data.accessControl.embed isnt "allowed"
      
      #set player variables from gdata return
      @ratio = 3/4
      @ratio = 9/16  if data.aspectRatio is "widescreen"
      @height = Math.round(@width * @ratio)
      @duration = data.duration
      

      tag = document.createElement("script")
      tag.src = "http://www.youtube.com/player_api"
      firstScriptTag = document.getElementsByTagName("script")[0]
      firstScriptTag.parentNode.insertBefore tag, firstScriptTag

      @setPlayerElements()
      ), "jsonp"

  setPlayerElements: ->
    @elements.control = $("#video_control")
    @elements.container = $("#video")
    if @progressBar
      @elements.progress = $("#progress_bar")
      @elements.elapsed = $(".elapsed")
      @setProgressBarEvents()

  resizePlayer: (width, speed) ->
    height = Math.round(width * @ratio)
    oldWidth =  $('iframe#video').width()
    transformRatio = width/oldWidth
    $('iframe#video').animate({width:"#{width}px", height:"#{height}px"}, speed)
    @elements.progress.animate({width:"#{width-2}px"}, speed)
    $('#q-markers').animate({width:"#{width-2}px"}, speed)

  setProgressBarEvents: ->
    @elements.progress.click (e) =>
      window.clearInterval reviewer.current_timer
      reviewer.teaching = false
      if e.target.className is "large" or e.target.className is "small"
        @questionDotClickEvent(e)
      else
        @progressBarClickEvent(e)

  questionDotClickEvent: (e)->
    @elements.player.pauseVideo()

    ##set progress bar and seek to location
    pos = $(e.target).parent().parent().parent().attr("style")
    sub = pos.substr(pos.indexOf(":") + 1, 6)
    ratio = (parseFloat(sub) / 100)
    @elements.elapsed.width ratio * 100 + "%"
    @elements.player.seekTo Math.round(@duration * ratio), true

    ##set dot click event actions
    if e.target.className is "small"
      question_id = parseInt($(e.target).attr("id"))
      reviewer.questions[reviewer.active_question_index].timer.pause()
      reviewer.active_question_index = question_id
      reviewer.loadQuestion()
      reviewer.next_question_time = reviewer.questions[reviewer.active_question_index].clip_end_time
      reviewer.onBeforeAsk()
    false

  progressBarClickEvent: (e)->
    @updateProgressBarWidth false

    ##set progress bar and seek to location
    ratio = (e.pageX - @elements.progress.offset().left) / @elements.progress.outerWidth()
    @elements.elapsed.width ratio * 100 + "%"
    @elements.player.seekTo Math.round(@duration * ratio), true

    ##check to see which question is next and load it
    q_widths = $(".q-marker-spacer").map((i, qms) ->
      sub = parseFloat($(qms).attr("style").substr($(qms).attr("style").indexOf(":") + 1, 6))
      sub)
    i = 0
    found = false
    until found
      if ratio * 100 < q_widths[i] or i >= q_widths.length
        found = true
      else
        i += 1

    ##set next question based on which index was found to be next
    if i >= q_widths.length
      reviewer.next_question_time = @duration + 1
    else
      reviewer.next_question_time = reviewer.questions[i].clip_end_time
      reviewer.active_question_index = i
      reviewer.loadQuestion()

    reviewer.hideQuestioner()
    false

  ##Interval for updating progress bar and checking for next question
  updateProgressBarWidth: (status) ->
    if status
      window.clearInterval window.interval
      window.interval = window.setInterval(=>
        @elements.elapsed.width ((@elements.player.getCurrentTime() / @duration) * 100) + "%"
        reviewer.checkForNextQuestion()
      , 250)
    else
      window.clearInterval window.interval


  ###
    VIDEO PLAYER CONTROLS
  ###
  getCurrentTime: ->
    if @elements.player
      @elements.player.getCurrentTime()

  pauseVideo: ->
    reviewer.teaching = false
    if @elements.player && @elements.player.pauseVideo
      @elements.player.pauseVideo()

  playVideo: ->
    if @elements.player && @elements.player.playVideo
      @elements.player.playVideo()

  seekTo: (seconds, allowSeekWithoutBuffer=true) ->
    if @elements.player and @elements.player.seekTo
      @elements.player.seekTo(seconds, allowSeekWithoutBuffer)

$ ->
  $.fn.youTubeEmbed =
    (settings)-> window.ytEmbed = new ytEmbed @eq(0), settings

  window.onYouTubePlayerAPIReady= =>
    console.log 'window.onYouTubePlayerAPIReady'
    startTime = 0

    ##sets the starting position of the bar and starttime of the video if it's a preloaded question
    if window.question_marker_id>=0
      pos = $(".q ##{window.question_marker_id}").parent().parent().parent().attr("style")
      reviewer.onBeforeAsk()
      sub = pos.substr(pos.indexOf(":") + 1, 6)
      ratio = (parseFloat(sub) / 100)
      window.ytEmbed.elements.elapsed.width ratio * 100 + "%"
      startTime = Math.round(window.ytEmbed.duration * ratio)


    ##Instantiates player
    window.ytEmbed.elements.player = new YT.Player("video",
      videoId: window.ytEmbed.videoID
      events:
        onReady: onYouTubePlayerReady

      id: "video_" + window.ytEmbed.safeID
      height: window.ytEmbed.height
      width: window.ytEmbed.width
      allowScriptAccess: window.ytEmbed.allowScriptAccess
      wmode: window.ytEmbed.wmode
      flashvars:
        video_id: window.ytEmbed.videoID
        playerapiid: window.ytEmbed.safeID

      playerVars:
        start: startTime
        controls: 1
        showinfo: 0
        fs: 1
        rel: 0
    )

  window.onAfterYouTubePlayerReady = (status) ->
    window.interval
    window.ytEmbed.elements.player.addEventListener "onStateChange", (state) ->
      switch state.data
        when 1
          window.ytEmbed.updateProgressBarWidth true
          reviewer.playToNextQuestion()  if reviewer.asking_question and not reviewer.teaching
        when 2
          window.ytEmbed.updateProgressBarWidth false
        else
          console.log state.data