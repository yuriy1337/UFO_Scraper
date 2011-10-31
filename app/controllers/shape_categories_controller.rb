class ShapeCategoriesController < ApplicationController
  # GET /shape_categories
  # GET /shape_categories.xml
  def index
    @shape_categories = ShapeCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shape_categories }
    end
  end

  # GET /shape_categories/1
  # GET /shape_categories/1.xml
  def show
    @shape_category = ShapeCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shape_category }
    end
  end

  # GET /shape_categories/new
  # GET /shape_categories/new.xml
  def new
    @shape_category = ShapeCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shape_category }
    end
  end

  # GET /shape_categories/1/edit
  def edit
    @shape_category = ShapeCategory.find(params[:id])
  end

  # POST /shape_categories
  # POST /shape_categories.xml
  def create
    @shape_category = ShapeCategory.new(params[:shape_category])

    respond_to do |format|
      if @shape_category.save
        format.html { redirect_to(@shape_category, :notice => 'Shape category was successfully created.') }
        format.xml  { render :xml => @shape_category, :status => :created, :location => @shape_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shape_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shape_categories/1
  # PUT /shape_categories/1.xml
  def update
    @shape_category = ShapeCategory.find(params[:id])

    respond_to do |format|
      if @shape_category.update_attributes(params[:shape_category])
        format.html { redirect_to(@shape_category, :notice => 'Shape category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shape_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shape_categories/1
  # DELETE /shape_categories/1.xml
  def destroy
    @shape_category = ShapeCategory.find(params[:id])
    @shape_category.destroy

    respond_to do |format|
      format.html { redirect_to(shape_categories_url) }
      format.xml  { head :ok }
    end
  end
end
