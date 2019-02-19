class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.select(:rating).map(&:rating).sort.uniq
    should_redirect = false
    if params[:ratings]
      @selected_ratings = params[:ratings]
      session[:ratings] = @selected_ratings
    elsif session[:ratings]
      @selected_ratings = session[:ratings]
      should_redirect = true
    else
      @selected_ratings = @all_ratings.product([1]).to_h
    end
    if params[:sort]
      @sort_by = params[:sort]
      session[:sort] = @sort_by
    elsif session[:sort]
      @sort_by = session[:sort]
      should_redirect = true
    else
      @sort_by = Hash.new
    end
    if should_redirect
      flash.keep
      redirect_to movies_path(sort: @sort_by, ratings: @selected_ratings)
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(@sort_by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
