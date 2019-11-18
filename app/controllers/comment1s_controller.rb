class Comment1sController < ApplicationController
  before_action :set_comment1, only: [:show, :edit, :update, :destroy]

  # GET /comment1s
  # GET /comment1s.json
  def index
    @comment1s = Comment1.all
  end

  # GET /comment1s/1
  # GET /comment1s/1.json
  def show
  end

  # GET /comment1s/new
  def new
    @comment1 = Comment1.new
  end

  # GET /comment1s/1/edit
  def edit
  end

  # POST /comment1s
  # POST /comment1s.json
  def create
    @comment1 = Comment1.new(comment1_params)

    respond_to do |format|
      if @comment1.save
        format.html { redirect_to @comment1, notice: 'Comment1 was successfully created.' }
        format.json { render :show, status: :created, location: @comment1 }
      else
        format.html { render :new }
        format.json { render json: @comment1.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comment1s/1
  # PATCH/PUT /comment1s/1.json
  def update
    respond_to do |format|
      if @comment1.update(comment1_params)
        format.html { redirect_to @comment1, notice: 'Comment1 was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment1 }
      else
        format.html { render :edit }
        format.json { render json: @comment1.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comment1s/1
  # DELETE /comment1s/1.json
  def destroy
    @comment1.destroy
    respond_to do |format|
      format.html { redirect_to comment1s_url, notice: 'Comment1 was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment1
      @comment1 = Comment1.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment1_params
      params.require(:comment1).permit(:content)
    end
end
