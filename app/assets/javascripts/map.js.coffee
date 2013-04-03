
$.fn.generateTemplate=(p)->
  source=@.html()
  template= Handlebars.compile source
  return template(p)

class @MapApp
  constructor:(option)->
    console.log option
    @map=@drag_area=@actual=@obj=@clickPos=@geoCoder=null
    @dummy=@z_index=0
    @markers={}
    @markerId=0 # latest marker ID
    lat=if option.lat isnt "" then option.lat else 37.77493
    lng=if option.lng isnt "" then option.lng else  -122.41942
    @homeLoc=new google.maps.LatLng lat, lng
    @countryCode=if option.country isnt "" then option.country else "US"
    @buildMap()
    @loadMap()
    @setupEvents()
    @mapId=option.mapId
  
  loadMap:->
    self=@
    $.post '/loadMarkers',{id:mapId},(r)->
      for i in r
        q=new google.maps.LatLng i.lat,i.lng
        self.createMarker q, i.markerId
      if r.length>0
        self.markerId=r.length-1
      console.log self.markerId

  buildMap:->
    self=@
    maps=google.maps
    console.log @homeLoc
    mapOption={
      center:@homeLoc
      zoom:9
      panControl:false
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    @map= new maps.Map document.getElementById('map'), mapOption
    @drag_area=document.getElementById "markers"
    marker= document.getElementById "marker"
    marker.onmousedown= (e)->
      self.dragHandler(e)

    @geoCoder=new google.maps.Geocoder()

  dragHandler:(e)->
    self=@
    e=window.event if !e
    @obj= e.target ? e.srcElement ? null
    
    if @obj.className!="drag"
      e.preventDefault() if e.cancelable
      @obj=null
      return
    else
      @z_index +=1
      @obj.style.zIndex=@z_index.toString()
      @obj.x=@obj.offsetLeft
      @obj.y=@obj.offsetTop
      @clickPos=@getMousePos(e)
      document.onmousemove=(e)->
        self.mousemoveHandler(e)
      document.onmouseup=(e)->
        document.onmousemove=null
        document.onmouseup=null
        self.obj =null if self.obj
      @dummy= new google.maps.OverlayView()
      @dummy.setMap(@map)
      @dummy.draw=()->
    return false


  mousemoveHandler:(e)->
    self=@
    if @obj && @obj.className=="drag"
      a=@getMousePos(e)
      l=@obj.x+a.x-@clickPos.x
      t=@obj.y+a.y-@clickPos.y
      @obj.style.left=l+"px"
      @obj.style.top=t+"px"
      @obj.onmouseup=(e)->
        self.mouseupHandler(e)
    return false

  mouseupHandler:(e)->
    self=@
    a = @map.getDiv()
    b = a.offsetLeft
    c = a.offsetTop
    f = a.offsetWidth
    d = a.offsetHeight
    h = @drag_area.offsetLeft
    i = @drag_area.offsetTop
    g = @obj.offsetWidth
    p = @obj.offsetHeight
    j = @obj.offsetLeft + h + g / 2
    k = @obj.offsetTop + i + p / 2

    if f > b and j<(b+f) and k>c and k<(c+d)
      # calcuate obj position relative to canvas
      w= new google.maps.Point j-b-1, k-c+(p/2)

      # get map canvas projection
      x=@dummy.getProjection()

      # get lat and long from canvas coordinate
      y=x.fromContainerPixelToLatLng(w)
      
      q="/img/markerPlus.png"
      # getting physical address 
      @geoCoder.geocode {'latLng':y}, (results,status)->
        if status is google.maps.GeocoderStatus.OK
          adr=results[0].formatted_address
          if self.markerId is 0 and $('#list .list_content div:first input').val() is ""
            $('#list .list_content div:first input').val adr
          else
            self.markerId+=1
            view=$('#des-template').generateTemplate({
              address: adr
              id:self.markerId
            })

            $('#list .list_content').append view
            self.onkeyupEvent()
          self.createMarker y, self.markerId
          
      @getNewMarker q

  getMousePos:(e)->
    b={}
    e=window.event if !e
    b.x=e.clientX
    b.y=e.clientY
    return b

  createMarker:(cor, id)->
    url="/img/marker#{id}.png"
    self=@
    d=google.maps
    icon_opt={
      url:url
      size: d.Size(32,32)
      anchor:d.Point(15,32)
    }
    marker= new d.Marker {
      position:cor
      map:@map
      clickable:false
      draggable:true
      raiseOnDrag:true
      icon:icon_opt
      zIndex:@z_index
    }
    d.event.addListener marker, "dragstart", ()->
      self.z_index+=1
      marker.setZIndex self.z_index
    marker.id=id
    @markers[id]=marker
    google.maps.event.addListener marker, 'drag',()->
      self.geoCoder.geocode {'latLng':marker.position}, (results,status)->
        if status is google.maps.GeocoderStatus.OK
          adr=results[0].formatted_address
          console.log adr
          console.log  $("input[marker=#{marker.id}]").val()

          $("input[marker=#{marker.id}]").val adr
  # get a new pin
  getNewMarker:(url)->
    self=@
    a=document.createElement "div"
    a.style.backgroundImage="url(#{url})"
    a.style.left="27px"
    a.style.top="10px"
    a.id=@obj.id
    a.className="drag"
    a.onmousedown=(e)->
      self.dragHandler(e)
    @drag_area.replaceChild a,@obj
    @obj=null
  
  setupEvents:->
    self=@
    # onkeyup event for existing input element 
    self.onkeyupEvent()
    $('#addDes').click ->
        self.markerId+=1
        t=$('#des-template').generateTemplate({
          address:""
          id:self.markerId
        })
        $('#list .list_content').append(t)
        # onkeyup event for dynamic input element 
        self.onkeyupEvent()
    $('#save span').click ->
      
      $('#save span').html("updating..")
      self.updateMap()

  updateMap:->
    self=@
    $.post '/update',@constructParams(), (status)->
      setTimeout( ->
        $('#save span').html("Save Plot")
      ,1000)

  constructParams:=>
    markers={}
    for k,v of @markers
      markers[k]={
        lat:v.position.lat()
        lng:v.position.lng()
        value:$("input[marker=#{k}]").val()
        map_id:@mapId
        markerId:k
      }
    params={
      id:@mapId
      map:{
        country:@countryCode
        value:$('.countrySearch').val()
        lat:@homeLoc.lat()
        lng:@homeLoc.lng()
      }
      markers:markers
    }

    return params

  onkeyupEvent:->
    self=@
    $('input').on "keyup", ->
       input=$(@)
       autocomplete=""
       if input.hasClass "countrySearch"
          autocomplete= new google.maps.places.Autocomplete @, {
            types:["(cities)"]
          }
       else
          autocomplete= new google.maps.places.Autocomplete @, {
            types:['geocode']
            componentRestrictions:{country:self.countryCode}
          }

       google.maps.event.addListener autocomplete, 'place_changed', ->
         q="http://maps.gstatic.com/mapfiles/ms/icons/ltblue-dot.png"
         y= autocomplete.getPlace().geometry.location
         if input.hasClass 'countrySearch'
           self.homeLoc=y
           self.geoCoder.geocode {'latLng':y}, (r,s)->
             if s== google.maps.GeocoderStatus.OK
               self.countryCode=r[r.length-1].address_components[0].short_name
           
           self.map.setZoom(8)
         else
           if self.markerId<=10 
             if !self.markers[input.attr('marker')]
              self.createMarker y,input.attr('marker')
              self.map.setZoom 10
             else
               #update marker position
               self.markers[ input.attr('marker')].setPosition y
              



         self.map.panTo(y)

