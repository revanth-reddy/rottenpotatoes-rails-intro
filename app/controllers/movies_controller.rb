class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort_by = params[:sort]
    submit_clicked = params[:submit_clicked]
    
    # Get all unique ratings
    @all_ratings = Movie.select(:rating).map(&:rating).uniq
    # Generate ratings that are selected
    generatedRatings = {}
    @all_ratings.each{ |rating| generatedRatings[rating] = 1 }
    
    ratings = {}
    # Storing and clearing Session based on sort params
    if(params[:sort])
      session[:sort_by] = params[:sort]
      @movies = Movie.order(params[:sort])
    elsif(session[:sort_by])
      @movies = Movie.order(session[:sort_by])
      @sort_by = session[:sort_by]
    else
      @movies = Movie.all
      session[:sort_by] = nil
    end

    # Saving and retrieving params based on refresh button click
    if(submit_clicked)
      if(!params[:ratings])
        if(session[:ratings])
          ratings = session[:ratings]
        else
          ratings = generatedRatings
          session[:ratings] = nil
        end
      else
        ratings = params[:ratings]
        session[:ratings] = ratings
      end
    elsif(params[:ratings]) 
      ratings = params[:ratings]
      session[:ratings] = ratings
    elsif(session[:ratings])
      ratings = session[:ratings]
    else
      ratings = generatedRatings
      session[:ratings] = nil
    end

    @ratings_to_show = ratings == generatedRatings ? generatedRatings.keys : ratings.keys
    @movies = @movies.with_ratings(ratings.keys)
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
