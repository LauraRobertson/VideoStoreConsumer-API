class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
    status: :ok,
    json: @movie.as_json(
    only: [:title, :overview, :release_date, :vote_average, :inventory],
    methods: [:available_inventory]
    )
    )
  end

  def create
    @movie = Movie.find_by(title: params[:title])

    if @movie
      @movie.inventory += 1
      @movie.save
    else
      if params[:title]
        @movie = MovieWrapper.search(params[:title])
        @movie[0].inventory = 1

        rating = ['G', 'PG', 'PG-13', 'R', 'NC-17']
        @movie[0].rating = rating.sample

        if @movie[0].save
          render status: :ok, json: { errors: { title: ["Movie with title #{params["title"]} saved!"] } }
        else
          render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
        end
      else
        render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
      end
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
