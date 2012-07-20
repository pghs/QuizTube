class LessonsController < ApplicationController
  before_filter :authenticate_user!
  # GET /lessons
  # GET /lessons.xml
  def index
    @lessons = Lesson.where(:user_id => current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @lessons }
    end
  end

  # GET /lessons/1
  # GET /lessons/1.xml
  def show
    @lesson = Lesson.find(params[:id])
  end

  # GET /lessons/new
  # GET /lessons/new.xml
  def new
    @lesson = Lesson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :json => @lesson }
    end
  end

  # GET /lessons/1/edit
  def edit
    @lesson = Lesson.find(params[:id])
  end

  # POST /lessons
  # POST /lessons.xml
  def create
    @lesson = Lesson.new(params[:lesson])
    @lesson.user_id = current_user.id
    respond_to do |format|
      if @lesson.save
        format.html { redirect_to(@lesson, :notice => 'Lesson was successfully created.') }
        format.xml  { render :json => @lesson, :status => :created, :location => @lesson }
      else
        format.html { render :action => "new" }
        format.xml  { render :json => @lesson.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lessons/1
  # PUT /lessons/1.xml
  def update
    @lesson = Lesson.new(params[:id])
    render :json => @lesson.id if @lesson.save      
  end

  # DELETE /lessons/1
  # DELETE /lessons/1.xml
  def destroy
    @lesson = Lesson.find(params[:id])
    @lesson.destroy
    render :nothing => true
  end

  def publish
    redirect_to "/" if current_user.user_type != "ADMIN" && current_user.user_type != "QC"
    book_ids = Authorship.where(:user_id => current_user.id).collect(&:book_id)
    @lessons = Lesson.where(:book_id => book_ids, :status => 2)
  end

  def add
    redirect_to "/" if current_user.user_type != "ADMIN"
    @books = Book.all
  end

  def update_status
    lesson = Lesson.find(params[:id])
    lesson.author_id = current_user.id if params[:status] == "1" and lesson.status == 0
    lesson.status = params[:status]
    lesson.save
    render :json => lesson
  end

  def export_to_csv
    require 'csv'

    @lesson = Lesson.find_by_id(params[:id])
    return if @lesson.nil?
    @questions = Question.where("lesson_id = ?", @lesson.id)

    csv_string_test = CSV.generate do |csv|
      csv << ["id", "question", "correct answer", "incorrect answer1", "incorrect answer2", "incorrect answer3", "topic"]

     @questions.each do |q|
        next if q.question.nil? || q.question.length < 1

        row = [ q.id, 
                clean_markup_from_desc(q.question), 
                clean_markup_from_desc(q.correct_answer), 
                clean_markup_from_desc(q.incorrect_answer1),
                clean_markup_from_desc(q.incorrect_answer2),
                clean_markup_from_desc(q.incorrect_answer3),
                clean_markup_from_desc(q.topic)]
        csv << row
      end
    end

    # send it to the browsah
    filename = "Lesson-#{@lesson.number}"
    send_data csv_string_test,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{filename}.csv"
  end


  private

  def get_lesson(id)
    lesson = Lesson.find_by_id(id)
    get_permission(lesson)
    @lesson = lesson if @w or @e
  end

  def get_permission(lesson)
    @e = @w = false
    return if lesson.nil?
    if Book.find(lesson.book_id).user_id == current_user.id || current_user.user_type == "ADMIN"
      @e = @w = true
    elsif Book.find(lesson.book_id).public
      @w = true
    end
  end

  def clean_markup_from_desc(str)
    return str if str.nil?
    str.gsub!("\s{2,}", " ")
    str.gsub!(" .", ".")
    str.gsub!("\n","")
    return str
  end  
end
