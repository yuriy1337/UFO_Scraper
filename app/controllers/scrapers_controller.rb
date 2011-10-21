$KCODE = "UTF-8"
class ScrapersController < ApplicationController
  require 'csv'
  require 'net/http'
  require 'uri'
  require 'hpricot'
  
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
          if(@states.length == 50)
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
        
        city_name = city_name.gsub(/ city/,'').gsub(/ town/,'').gsub(/ village/,'').gsub(/ CDP/,'').gsub(/ City/,'')
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
  
  def airport_scaper
    #@airports = Array.new
    #@cities = City.all
    
    #CSV.foreach("data/DEC_10_SF1_GCTPH1.ST13.csv") do |row|
    #  if(row[4].eql("USA"))
    #    next
    #  else
        #@cities.each do |city|
          #city_id = nil
          #if(city.name.downcase.eql(row[3].downcase)
          #  city_id = city.id
          #end
        #end
        #airport = Airport.new(
        #  :icao => row[0],
        #  :iata => row[1],
        #  :name => row[2],
        #)
    #end
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
