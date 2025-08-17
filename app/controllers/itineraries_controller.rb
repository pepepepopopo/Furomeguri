class ItinerariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_itinerary, only: %i[edit update show]

  def index
    @itineraries = current_user.itineraries.order(created_at: :desc)
  end

  def show
    @blocks = @itinerary.itinerary_blocks.includes(:place).order(:created_at)
  end

  def new
    @itinerary = current_user.itineraries.new
  end

  def edit
    @default_locations = DefaultLocation.all
    @blocks            = @itinerary.itinerary_blocks.rank(:row_order)
  end

  def create
    @itinerary = current_user.itineraries.build(itinerary_params)
    @itinerary.title = "タイトル未定" if @itinerary.title.blank?
    if @itinerary.save
      redirect_to edit_itinerary_path(@itinerary), notice: "新規旅行計画を作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @itinerary.update!(itinerary_params)
    if params[:blocks].present?
      ActiveRecord::Base.transaction do
        itinerary_blocks_params.each do |attrs|
          # 何も変更が無ければスキップ
          next if attrs[:description].blank? && attrs[:starttime].blank? && attrs[:_destroy].blank?

          if ActiveModel::Type::Boolean.new.cast(attrs[:_destroy])
            @itinerary.itinerary_blocks.find_by(id: attrs[:id])&.destroy!
            next
          end

          if attrs[:id].present?
            @itinerary.itinerary_blocks.find(attrs[:id]).update!(
              description: attrs[:description],
              starttime: parse_time(attrs[:starttime])
            )
          else
            place = find_or_create_place(attrs)
            @itinerary.itinerary_blocks.create!(
              place: place,
              description: attrs[:description],
              starttime: parse_time(attrs[:starttime])
            )
          end
        end
      end
    end
    redirect_to itineraries_path, notice: "更新しました"
  end

  def destroy
    itinerary = current_user.itineraries.find(params[:id])
    itinerary.destroy!
    redirect_to itineraries_path, notice: "削除しました", status: :see_other
  end

  private

  def set_itinerary
    @itinerary = current_user.itineraries.find(params[:id])
  end

  def itinerary_params
    params.require(:itinerary).permit(:title, :subtitle)
  end

  def itinerary_blocks_params
    params.require(:blocks).map do |block|
      block.permit(
        :id, :description, :starttime,
        :google_place_id, :name, :lat, :lng, :place_id, :_destroy
      )
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

  # 文字列(YYYY-MM-DDTHH:MM) → Time.zone
  def parse_time(raw)
    return nil if raw.blank?

    Time.zone.parse(raw.to_s)
  rescue ArgumentError
    nil
  end
end
