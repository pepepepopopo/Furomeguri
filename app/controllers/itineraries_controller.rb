class ItinerariesController < ApplicationController
  before_action :set_itinerary, only: %i[edit update show]
  def index
    @itineraries = Itinerary.order(created_at: :desc)
  end

  def new
    @itinerary = Itinerary.new
  end

  def create
    @itinerary = Itinerary.new(itinerary_params)
    if @itinerary.save
      redirect_to edit_itinerary_path(@itinerary), notice: "新規旅行計画を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @blocks = @itinerary.itinerary_blocks
  end

  def update
    @itinerary = itineraries.find_by(params[:id])
    if @itinerary.update(itinerary_params)
      redirect_to edit_itinerary_path(@Itinerary), notice: "更新しました"
    else
      @blocks = @itinerary.itinerary_blocks
      render :edit, status: :unprocessable_entity
    end
  end

  def show
  end

  def destroy
    itinerary = itineraries.find(params[:id])
    itinerary.destroy!
    redirect_to itineraries_path, notice: "削除しました", status: :see_other
  end

  private

  def set_itinerary
    @itinerary = Itinerary.find(params[:id])
  end
  def itinerary_params
    params.require(:itinerary).permit(:title, :subtitle)
  end
end
