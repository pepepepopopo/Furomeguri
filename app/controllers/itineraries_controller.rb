class ItinerariesController < ApplicationController
  before_action :set_itinerary, only: %i[edit update show destroy]
  def index
    @itineraries = Itinerary.order(created_at: :desc)
  end

  def new
    @itinerary = Itinerary.new
  end

  def show
    @blocks = @itinerary.itinerary_blocks.includes(:place).order(:created_at)
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
    @default_locations = DefaultLocation.all
    @blocks = @itinerary.itinerary_blocks
  end

  def update
    @itinerary = Itinerary.find_by!(id: params[:id])
    ActiveRecord::Base.transaction do
      itinerary_blocks_params.each do |attrs|
        # paramsが空なら何もしない
        next if attrs[:description].blank? && attrs[:starttime].blank? && attrs[:_destroy].blank?
        # 削除フラグがあれば削除
        if ActiveModel::Type::Boolean.new.cast(attrs[:_destroy])
          ItineraryBlock.find_by(id: attrs[:id])&.destroy!
          next
        end
        if attrs[:id].present?
          ItineraryBlock.find(attrs[:id]).update!(
            description: attrs[:description],
            starttime: parse_time(attrs[:starttime])
          )
        else
          # 新規ブロック作成
          place = find_or_create_place(attrs)
          @itinerary.itinerary_blocks.create!(
            place: place,
            description: attrs[:description],
            starttime: parse_time(attrs[:starttime])
          )
        end
      end
    end
    redirect_to itinerary_path(@itinerary), notice: "更新しました"
  end

  def destroy
    itinerary = Itinerary.find(params[:id])
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

  def itinerary_blocks_params
    params.require(:blocks).map do |block|
      block.permit(:id, :description, :starttime, :google_place_id, :name, :lat, :lng, :place_id, :_destroy)
    end
  end

  def find_or_create_place(attrs)
  if attrs[:place_id].present?
    Place.find(attrs[:place_id])
  else
    Place.find_or_create_by!(google_place_id: attrs[:google_place_id]) do |p|
      p.name = attrs[:name]
      p.lat  = attrs[:lat]
      p.lng  = attrs[:lng]
    end
  end
end
end
