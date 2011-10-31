class ScrapersController < ApplicationController
  require 'csv'
  require 'net/http'
  require 'uri'
  require 'hpricot'
  
  RAD_PER_DEG = 0.017453293  #  PI/180
  Rmiles = 3956           # radius of the great circle in miles
  Rkm = 6371              # radius in kilometers...some algorithms use 6367
  Rfeet = Rmiles * 5282   # radius in feet
  Rmeters = Rkm * 1000    # radius in meters

  
  # GET /scrapers
  # GET /scrapers.xml
  
  def city_scraper
    #Id,Id2,Geography,Target Geo Id,Target Geo Id2,Geographical Area,Geographical Area,,,Total area,Water area,Land area,Population,Housing  units
    #0400000US01,01,Alabama,1600000US0107000,0107000,"Alabama - PLACE - Birmingham city, Alabama","Birmingham city, Alabama",242820,111927,151.95,2.04,149.92,1619.7,746.6
    #     0      1    2             3            4                          5                                      6            7     8      9     10    11     12    13  
    @states = Array.new
    @cities = Array.new
    
    count = 0
    state_name = ""
    CSV.foreach("data/DEC_10_SF1_GCTPH1.ST13.csv") do |row|
      count = count + 1
      city_name = ""
      population = 0
      elevation = 0
      lat_dir = ""
      lat_deg = 0
      lat_min = 0
      lat_sec = 0
      lon_dir = ""
      lon_deg = 0
      lon_min = 0
      lon_sec = 0
        if(row[2] == row[5])
          #its a state
          puts "State: #{row[2]}"
          state_name = row[2]
          state = State.new(:name => row[2])
          if(@states.length == 51)
            break
          end
          @states << state
          next
        end
        
        geographical_area = CSV.parse(row[6])
        city_name = geographical_area[0][0]
        if(city_name.match(/(part)/))
          #puts "skipping #{city_name}"
          next
        end
        
        city_name = city_name.downcase.gsub(/ city/,'').gsub(/ town/,'').gsub(/ village/,'').gsub(/ cdp/,'').gsub(/ borough/,'').gsub(/ municipality/,'').gsub(/ and/,'')
        city_name.strip.capitalize!
        city_name = city_name.capitalize
        #puts "#{city_name} #{count}"
        
        city_name_uri = URI.escape(city_name, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        state_name_uri = URI.escape(state_name, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        city_html = Net::HTTP.get(URI.parse("http://www.geonames.org/search.html?q=#{city_name_uri}%2C+#{state_name_uri}&country=US"))
        #puts "http://www.geonames.org/search.html?q=#{city_name}%2C+#{state_name}&country=US"
        @city_doc = Hpricot(city_html)
        
        @city_doc.search("//table[@class='restable']") do |table|
          tr_count = 0
          table.search("//tr") do |tr|
            #puts "in tr search"
            tr_count = tr_count + 1
            if(tr_count < 3)
              next
            end
            #puts "in tr search 2"
            td_count = 0
            tr.search("//td") do |td|
              #puts "in td search"
              td_count = td_count + 1
              if(td_count < 4)
                next
              end
              if(td_count == 4)
                td.search("//small") do |small|
                  #population = "#{small.match(/\\d+/)[1]}"
                  #puts "!!!!!!!!!!!!!!!!!!"
                  #puts td_count
                  #puts "#{small.inner_html}"
                  #puts "!!!!!!!!!!!!!!!!!!"
                  pop_elev = small.inner_html
                  #population = "#{pop_elev.match(/\d+,\d*/)}".gsub(/,/,'')
                  elevation = "#{pop_elev.match(/\d+m/)}".gsub(/m/,'')
                  #puts population
                  #puts elevation
                end
              end
              if(td_count == 5)
                lat_dir = td.inner_html[0]
                matches = td.inner_html.scan(/(\d+)/)
                lat_deg = matches[0][0]
                lat_min = matches[1][0]
                lat_sec = matches[2][0]
              end
              if(td_count == 6)
                lon_dir = td.inner_html[0]
                matches = td.inner_html.scan(/(\d+)/)
                lon_deg = matches[0][0]
                lon_min = matches[1][0]
                lon_sec = matches[2][0]
              end
            end
            break
            
          end       
        end
        city = City.new(
          :name => city_name,
          :states_id => @states.length,
          :total_area => row[9],
          :water_area => row[10],
          :land_area => row[11],
          :population => row[7],
          :population_density => row[12],
          :lat_deg => lat_deg,
          :lat_min => lat_min,
          :lat_sec => lat_sec,
          :lat_dir => lat_dir,
          :lon_deg => lon_deg, 
          :lon_min => lon_min,
          :lon_sec => lon_sec,
          :lon_dir => lon_dir,
          :elevation => elevation)
          
          @cities << city
        if(count % 10 == 0)
          puts count
        end
    end
    
    @states.each do |state|
      state.save
    end
    
    @cities.each do |state|
      state.save
    end
    
  end
  
  def airport_scraper
    @airports = Array.new
    @cities = City.all
    puts "hi"
	count = 0
    CSV.foreach("data/GlobalAirportDatabase.txt") do |row|
      if(row[4].eql?("USA") && row[5].to_i != 0)
        #@cities.each do |city|
        #  city_id = nil
        #  if(city.name.downcase.eql(row[3].downcase))
        #    city_id = city.id
        #  end
        #end
  		city_name = row[3]
  		city_name = city_name.downcase.gsub(/ city/,'').gsub(/ town/,'').gsub(/ village/,'').gsub(/ cdp/,'').gsub(/ borough/,'').gsub(/ municipality/,'').gsub(/ and/,'')
  		
  		city = @cities.detect { |h| h[:name].downcase == city_name && h[:lat_deg] == row[5].to_i && h[:lon_deg] == row[9].to_i}
  		puts "#{city_name} #{row[5]} #{row[9]}" 
  		
  		city_id = nil
  		if(!city.nil?)
  		    city_id = city.id
  	  end
  		airport = Airport.new(
  		  :icao => row[0],
  		  :iata => row[1],
  		  :name => row[2],
  		  :cities_id => city_id,
  		  :lat_deg => row[5],
  		  :lat_min => row[6],
  		  :lat_sec => row[7],
  		  :lat_dir => row[8],
  		  :lon_deg => row[9],
  			:lon_min => row[10],
  			:lon_sec => row[11],
  			:lon_dir => row[12],
  			:altitude => row[13],
  	 ) 
  	 @airports << airport
     else
        next
     end
	 if(count > 10)
		#break
	end
	count = count + 1
    end
    
    @airports.each do |airport|
      airport.save
    end
    
  end
  
  def sighting_scraper
    @states = State.all
    @cities = City.all
    @sightings = Array.new
    @to_19 = [ "zero",  "one",   "two",  "three", "four",   "five",   "six",
        "seven", "eight", "nine", "ten",   "eleven", "twelve", "thirteen",
        "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen" ]
        
    @tens  = [ "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"]
    sighting_info_url = "http://www.nuforc.org/webreports/"
    
    sightings_html = Net::HTTP.get(URI.parse("http://www.nuforc.org/webreports/ndxloc.html"))
    @sightings_doc = Hpricot(sightings_html)
    
    @sightings_doc.search("//table") do |table|
      tr_count = 0 
      table.search("//tr") do |tr|
        td_count = 0
        tr.search("//td") do |td|
          if(td_count == 0)
            font = td.at("font")
            state_name = font.at("a").inner_html
            state = @states.detect { |h| h[:name].downcase == state_name.downcase }
            if(!state.nil?)
              state_id = state.id 
              puts "state_id= #{state_id}"
              state_url = ""
              
              font.search("a").map {|e| state_url = e.get_attribute("href") }
              puts state_url
              
              sightings_info_html = Net::HTTP.get(URI.parse(sighting_info_url + state_url))
              @sightings_info_doc = Hpricot(sightings_info_html)
              
              @sightings_info_doc.search("//table") do |table2|
                tr_c = 0
                table2.at("tbody").search("//tr") do |tr2|
                  td_c = 0
                  occurance_time = nil
                  cities_id = nil
                  shape_categories_id = nil
                  duration = 0.0
                  summary = ""
                  post_date = nil
                  tr2.search("//td") do |td2|
                    #puts td2.inner_html
                    if(td_c == 0)
                      date_time = td2.at("font").at("a").inner_html.scan(/(\d+)/)
                      year = 0
                      begin
                        if(date_time[2][0].to_i >= 0 && date_time[2][0].to_i <= 11)
                          year = date_time[2][0].to_i + 2000
                        else
                          year = date_time[2][0].to_i + 1900
                        end
                        if(td2.at("font").at("a").inner_html.length > 8)
                          occurance_time = Time.new(year,date_time[0][0], date_time[1][0], date_time[3][0], date_time[4][0])
                        else
                          occurance_time = Time.new(year,date_time[0][0], date_time[1][0])
                        end
                      rescue
                        #nothing much i can do, it will be nil
                      end
                      #puts occurance_time
                    end
                    if(td_c == 1)
                      
                      city_name = td2.at("font").inner_html.gsub(/ \(.*\)/,'')
                      city = @cities.detect { |h| h[:name].downcase.include?(city_name.downcase.strip) && h[:states_id] == state_id}
                      puts city_name
                      if(!city.nil?)
                        cities_id = city.id
                      end
                    end
                    if(td_c == 3)
                      shape = td2.at("font").inner_html
                      shape = shape.downcase
                      if(shape.include?("light") || shape.include?("flash") || shape.include?("flare"))
                        shape_categories_id = 1
                      end
                      if(shape.include?("<br />") || shape.include?("unknown") || shape.include?("other"))
                        shape_categories_id = 2
                      end
                      if(shape.include?("circle") || shape.include?("round") || shape.include?("crescent") || shape.include?("dome"))
                        shape_categories_id = 3
                      end
                      if(shape.include?("triangle") || shape.include?("chevron") || shape.include?("cone") || shape.include?("delta") || shape.include?("pyramid"))
                        shape_categories_id = 4
                      end
                      if(shape.include?("disk"))
                        shape_categories_id = 5
                      end
                      if(shape.include?("fireball") || shape.include?("teardrop"))
                        shape_categories_id = 6
                      end
                      if(shape.include?("oval") || shape.include?("egg"))
                        shape_categories_id = 7
                      end
                      if(shape.include?("cigar") || shape.include?("cylinder"))
                        shape_categories_id = 8
                      end
                      if(shape.include?("rectangle") || shape.include?("diamond") || shape.include?("hexagon") || shape.include?("cross"))
                        shape_categories_id = 9
                      end
                      if(shape.include?("formation"))
                        shape_categories_id = 10
                      end
                      if(shape.include?("changing") || shape.include?("changed"))
                        shape_categories_id = 11
                      end
                      if(shape_categories_id.nil?)
                        shape_categories_id = 2
                      end
                    end
                    if(td_c == 4)
                      #puts "!!!!"
                      d_str = td2.at("font").inner_html.downcase
                      #puts d_str
                      numbers = d_str.scan(/(\d+)/)
                      numbers.each do |n|
                        duration = duration + n[0].to_f
                      end
                      if(numbers.length > 0)
                        duration = duration/numbers.length
                      else
                        @tens.each_with_index do |str, i|
                          if(d_str.include?(str))
                            duration += (i + 2) * 10
                            break
                          end
                        end
                        @to_19.each_with_index do |str, i|
                          if(d_str.include?(str))
                            duration += i
                            break
                          end
                        end
                        if(duration == 0)
                          duration = 1.0
                        end
                        #puts "found string duration:"
                        #puts duration
                        #puts "end found"
                      end
                      
                      if(d_str.include?("min"))
                        duration = duration * 60
                      end
                      
                      if(d_str.include?("hour") || d_str.include?("hr"))
                        duration = duration * 3600
                      end
                      
                      if(d_str.include?("day"))
                        duration = duration * 86400
                      end
                      
                      if(d_str.include?("week"))
                        duration = duration * 604800
                      end
                      #puts duration
                      if (duration.infinite? != nil)
                        puts "Duration is infinite"
                        return
                      end
                    end
                    if(td_c == 5)
                      summary = td2.at("font").inner_html
                    end
                    if(td_c == 6)
                      date = td2.at("font").inner_html.scan(/(\d+)/)
                      year = 0
                      if(date[2][0].to_i >= 0 && date[2][0].to_i <= 11)
                        year = date[2][0].to_i + 2000
                      else
                        year = date[2][0].to_i + 1900
                      end
                        post_date = Time.new(year,date[0][0], date[1][0])
                    end
                    td_c = td_c + 1
                  end
                  sighting = Sighting.new(:occurance_time => occurance_time,
                                            :cities_id => cities_id,
                                            :shape_categories_id => shape_categories_id,
                                            :duration => duration,
                                            :summary => summary,
                                            :post_date => post_date)
                  #puts sighting
                  @sightings << sighting
                  #puts tr_c
                  #if(tr_c > 10)
                  #  break
                  #end
                  tr_c = tr_c + 1
                end
              end
            end
          end
          td_count = td_count + 1
        end
        tr_count = tr_count + 1
        if(tr_count % 10 == 0) 
          puts tr_count
          #break
        end
      end
    end
    
    @sightings.each do |s|
      s.save
    end
    
  end
  
  def weatherstation_scraper
    @states = State.all
    @cities = City.all
    @weather_stations = Array.new
    count = 0
    CSV.foreach("data/COOP-ACT.csv") do |row|
      state = @states.detect { |h| h[:abbr].downcase == row[3].downcase }
      city = @cities.detect { |h| h[:name].downcase == row[6].downcase }
      city_id = nil
      if(!city.nil?)
        city_id = city.id
      end
      ws = WeatherStation.new(
        :nws => row[1],
        :states_id => state.id,
        :cities_id => city_id,
        :name => row[6],
        :lat_deg => row[7].to_i,
        :lat_min => row[8].to_i,
        :lat_sec => row[9].to_i,
        :lat_dir => "N",
        :lon_deg => row[10].to_i.abs,
        :lon_min => row[11].to_i,
        :lon_sec => row[12].to_i,
        :lon_dir => "W",
        :elevation => row[13],
      )
      if(count % 100 == 0)
        puts count
      end
      count = count + 1
      @weather_stations << ws
    end
    
    WeatherStation.transaction do
      @weather_stations.each do |ws|
        ws.save
      end
    end
    
  end
  
  
  def sighting_airport_distance
    @sightings = Sighting.all
    @cities = City.all
    @airports = Airport.all
    
    min_distance = 999999999
    min_distance_id = 0
    @sightings.each do |s|
      city = @cities.detect { |h| h[:id] == s.cities_id }
       if(!city.nil?)
         @airports.each do |a|
           dist = haversine_distance(city.lat, city.lon, a.lat, a.lon)
           if(dist < min_distance)
             min_distance = dist
             min_distance_id = a.id 
           end
         end
         puts min_distance
         puts min_distance_id
         Sighting.update(s.id, :airport_id => min_distance_id, :airport_distance => min_distance)
       end
    end
  end
  
def haversine_distance( lat1, lon1, lat2, lon2 )
  dlon = lon2 - lon1
  dlat = lat2 - lat1
  dlon_rad = dlon * RAD_PER_DEG
  dlat_rad = dlat * RAD_PER_DEG
  lat1_rad = lat1 * RAD_PER_DEG
  lon1_rad = lon1 * RAD_PER_DEG
  lat2_rad = lat2 * RAD_PER_DEG
  lon2_rad = lon2 * RAD_PER_DEG

  a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
  
  c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
  
   
  
  dMi = Rmiles * c          # delta between the two points in miles
  #dKm = Rkm * c             # delta in kilometers
  #dFeet = Rfeet * c         # delta in feet
  #dMeters = Rmeters * c     # delta in meters

  #@distances["mi"] = dMi

  #@distances["km"] = dKm
  #@distances["ft"] = dFeet
  #@distances["m"] = dMeters
end

  
  def index
    @scrapers = Scraper.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scrapers }
    end
  end

  # GET /scrapers/1
  # GET /scrapers/1.xml
  def show
    @scraper = Scraper.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scraper }
    end
  end

  # GET /scrapers/new
  # GET /scrapers/new.xml
  def new
    @scraper = Scraper.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scraper }
    end
  end

  # GET /scrapers/1/edit
  def edit
    @scraper = Scraper.find(params[:id])
  end

  # POST /scrapers
  # POST /scrapers.xml
  def create
    @scraper = Scraper.new(params[:scraper])

    respond_to do |format|
      if @scraper.save
        format.html { redirect_to(@scraper, :notice => 'Scraper was successfully created.') }
        format.xml  { render :xml => @scraper, :status => :created, :location => @scraper }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scraper.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scrapers/1
  # PUT /scrapers/1.xml
  def update
    @scraper = Scraper.find(params[:id])

    respond_to do |format|
      if @scraper.update_attributes(params[:scraper])
        format.html { redirect_to(@scraper, :notice => 'Scraper was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scraper.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scrapers/1
  # DELETE /scrapers/1.xml
  def destroy
    @scraper = Scraper.find(params[:id])
    @scraper.destroy

    respond_to do |format|
      format.html { redirect_to(scrapers_url) }
      format.xml  { head :ok }
    end
  end
end
