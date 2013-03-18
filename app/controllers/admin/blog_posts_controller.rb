class Admin::BlogPostsController < Admin::BaseController

  def index
    if params[:blog_id]
      @blog = Blog.find(params[:blog_id])
      @blog_posts = Blog::Post.where(blog: @blog.id).page(params[:page])
    end
  end

  def new
    @blog_post = Blog::Post.new(blog: params[:blog_id])
  end

  def create
    @blog_post = update_blog_post(Blog::Post.new)
    if @blog_post.save
      redirect_to admin_blog_posts_path(params[:blog_id])
    else
      render 'new'
    end
  end

  def edit
    @blog_post = Blog::Post.find(params[:id])
  end

  def update
    @blog_post = update_blog_post(Blog::Post.find(params[:id]))
    if @blog_post.update_attributes(params[:blog_post])
      redirect_to admin_blog_posts_path(params[:blog_id])
    else
      render 'edit'
    end
  end

  def destroy
    blog_post = Blog::Post.find(params[:id])
    blog_post.destroy
    flash[:success] = %Q[Blog post "#{blog_post.title}" was deleted.]
    redirect_to admin_blog_posts_path(params[:blog_id])
  end


  private

  def update_blog_post(blog_post)
    # Last element of taxonomy array may be an empty string
    author_name = params[:blog_post].delete(:author_id)
    blog_post.assign_attributes(params[:blog_post])
    unless author_name.blank?
      blog_post.author = Staff.find_or_create_by_name(author_name)
    end
    blog_post
  end

end
