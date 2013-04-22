# encoding: utf-8
class QuestionsController < ApplicationController
  before_filter :authenticate_user!, only: [:edit, :update, :destroy, :new, :create]
  load_and_authorize_resource only: [:update, :edit, :destroy]

  # GET /questions
  # GET /questions.json
  def index
    if params[:tag]
      @questions = Question.tagged_with(params[:tag]).page(params[:page]).per_page(5)
    else
      @questions = Question.order("title").page(params[:page]).per_page(5)
    end
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    @question = Question.find(params[:id])
    Question.viewed(@question, cookies)
    @answers = @question.answers
    @answer = Answer.new
  end

  # GET /questions/new
  # GET /questions/new.json
  def new
    @question = Question.new
  end

  # GET /questions/1/edit

  # POST /questions
  # POST /questions.json
  def create
    @question = current_user.questions.new(params[:question])

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: "new" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update_attributes(params[:question])
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    flash[:success] = "问题删除成功"
    redirect_to questions_url
  end

  def evaluate
    if QuestionEvaluation.where(user_id: current_user.id ,question_id: params[:question_id]).size == 0
     QuestionEvaluation.create(user_id: current_user.id,question_id: params[:question_id],score: params[:score])
      flash[:success] = "恭喜您,评价成功"
    else
      flash[:error] = "非常抱歉，一个问题您只能评价一次！"
    end
    redirect_to "/questions/"+params[:question_id]
  end
end
