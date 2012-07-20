require 'csv'

class QuestionsController < ApplicationController
  # include ActionView::Helpers::SanitizeHelper

  # GET /questions
  # GET /questions.xml
  def index
    @questions = Question.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    @question = Question.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    @question = Question.new
    render :json => {:question_id => @question.id}.to_json
    # respond_to do |format|
    #   format.html # new.html.erb
    #   format.xml  { render :xml => @question }
    # end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = Question.new(params[:question])
    # @question.user_id = current_user.id
    render :json => @question.id if @question.save
    # respond_to do |format|
    #   if @question.save     
    #     format.html { redirect_to(@question, :notice => 'Question was successfully created.') }
    #     format.xml  { render :xml => @question, :status => :created, :location => @question }
    #   else    
    #     format.html { render :action => "new" }
    #     format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id])
    @question.update_attributes(params[:question])
    render :json => @question.id if @question.save
    # respond_to do |format|
    #   if @question.update_attributes(params[:question])
    #     format.html { redirect_to(@question, :notice => 'Question was successfully updated.') }
    #     format.xml  { head :ok }
    #   else
    #     format.html { render :action => "edit" }
    #     format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    @question.destroy
    render :nothing => true
    # respond_to do |format|
    #   format.html { redirect_to(Chapter.find_by_id(@question.chapter_id)) }
    #   format.xml  { head :ok }
    # end
  end

  def get_permission
    render :json => Question.find(params[:id]).user_id.to_i == current_user.id.to_i || current_user.user_type == "ADMIN"
  end

  def save_question
    if params[:question_id].to_i == -1
      @question = Question.create!(:question => params[:question],
        :correct_answer => params[:correct_answer],
        :incorrect_answer1 => params[:incorrect_answer1],
        :incorrect_answer2 => params[:incorrect_answer2],
        :incorrect_answer3 => params[:incorrect_answer3],
        :topic => params[:topic],
        :chapter_id => params[:chapter_id],
        :user_id => current_user.id
      )
    else
      @question = Question.find_by_id(params[:question_id])
      @question.question = params[:question]
      @question.correct_answer = params[:correct_answer]
      @question.incorrect_answer1 = params[:incorrect_answer1]
      @question.incorrect_answer2 = params[:incorrect_answer2]
      @question.incorrect_answer3 = params[:incorrect_answer3]
      @question.topic = params[:topic]
      @question.chapter_id = params[:chapter_id]
      @question.user_id = current_user.id if @question.user_id.nil?
      @question.save
    end
    render :json => @question.id
  end
end