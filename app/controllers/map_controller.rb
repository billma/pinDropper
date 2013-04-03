class MapController < ApplicationController
  def new
    newMap=Map.create()
    redirect_to "/map/#{newMap.id}"    
  end 
  def show
    @map=Map.find(params[:id])
    @markers=@map.markers.reverse()
    p "-------" 
    p "-------" 
    p "-------" 
    p @map.markers 
    p "-------" 
    p "-------" 
    p "-------" 
   
  end
  def update
    map=Map.find(params[:id])
    
    map.update_attributes(
      :country=>params[:map][:country],
      :value=>params[:map][:value],
      :lat=>params[:map][:lat],
      :lng=>params[:map][:lng]
    )
    if params[:markers]
      params[:markers].each do |k,v|
        m=Marker.where(:map_id=>params[:id],:markerId=>k ).first_or_create do |marker|
          marker.lat=v[:lat]
          marker.lng=v[:lng]
          marker.value=v[:value]
          marker.map_id=v[:map_id]
          marker.markerId=v[:markerId]
        end 
        m.update_attributes(
          :lat=>v[:lat],
          :lng=>v[:lng],
          :value=>v[:value],
          :map_id=>v[:map_id],
          :markerId=>v[:markerId]
        )
      p "--------" 
      p "--------" 
      p "--------" 
      p m 
      p "--------" 
      p "--------" 
      p "--------" 
      end 
    end 
   render :json=> params 
  end 
  def loadMarkers
    markers=Map.find(params[:id]).markers
    render :json=> markers
  end 
end
