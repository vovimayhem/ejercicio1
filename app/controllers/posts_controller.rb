class PostsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  def index
    @posts = Post.all
  end

  # GET /posts/1
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    return create_later if params.dig('post', 'delayed') == 'yes'
    @post = Post.new(post_params)
    @post.author = current_user

    if @post.save
      redirect_to @post, notice: 'Post was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /posts/1
  def update
    return update_later if params.dig('post', 'delayed') == 'yes'
    if @post.update(post_params)
      redirect_to @post, notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to posts_url, notice: 'Post was successfully destroyed.'
  end

  private

    def create_later
      ProcessPostJob.perform_later post_params.to_h, current_user
      redirect_to posts_path, notice: 'Post is being created.'
    end

    def update_later
      ProcessPostJob.perform_later post_params.to_h, current_user, @post
      redirect_to posts_path, notice: 'Post is being updated.'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def post_params
      params.require(:post).permit(:body)
    end
end
