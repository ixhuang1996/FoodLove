class FarmsController < ApplicationController

  def index
    @farms=Farm.all
  end

  def show
    @farm=Farm.find(params[:id])
  end

  def new
    @farm=Farm.new
  end

  def edit
    @user=User.find(params[:id])
    @farm=Farm.find(params[:id])
    @orders=@farm.orders
    @products = @farm.products.sort_by{|p| [p.quantity>0 ? 0:1,
                                 p.category.downcase,
                                 p.name.downcase,
                                 p.price]}
  end

  def create
    @farm=Farm.new(params[:user])
    if @farm.save
      redirect_to @farm
    else 
      render User.new
    end
  end

  def update
    @farm=Farm.find(params[:id])
    @farm.update(farm_params)

    @farm.update_attribute(:location, params[:farm][:location])
    @farm.update_attribute(:name, params[:farm][:name]) 
    @farm.update_attribute(:email, params[:farm][:email])

    if params[:farm][:products_attributes] != nil
      redirect_to farm_products_path(@farm)
    else
      redirect_to edit_farm_path(@farm)
    end
  end

  def upload
    @farm=Farm.find(params[:id])

    #uncheck all
    @farm.products.each do |product|
      product.update(quantity: 0)
    end

    #upload
    uploader = FileUploader.new
    uploader.store!(params[:farm][:file])

    book = Spreadsheet.open(Rails.root.join('public', 'uploads',
    	   				    params[:farm][:file].original_filename))
    sheet = book.worksheet 0
    
    #process products
    sheet.each 2 do |row|
      if row[2]==nil
        break
      end
      #if product with name and unit exists, update
      if @farm.products.exists?(name: row[1], unit: row[2])
        @id = @farm.products.where(name: row[1], unit: row[2])
	@farm.products.update(@id, {:category => row[0],
				    :price => row[3],
				    :quantity => row[4],
				    :description => row[5],
				    :notes => row[6]})
      else
        @farm.products.create(name: row[1],
	                      unit: row[2],
			      category: row[0],
			      price: row[3],
			      quantity: row[4],
			      description: row[5],
			      notes: row[6])
      end
    end
    redirect_to farm_products_path(@farm)

  end

  def sendnotif
    @farm = Farm.find(params[:id])
    @buyers = @farm.buyers #find all the buyers
    @dists = @farm.distributors #find all the distributors
    
    #send email to each buyer and distributor
    @buyers.each do |b|	
      UserMailer.notif(b,params[:notification][:notif],@farm).deliver_now
    end

    @dists.each do |d|
      UserMailer.notif(d,params[:notification][:notif],@farm).deliver_now
    end

    #create notification object
    puts @farm.notifications.create(notif: params[:notification][:notif]).created_at


    redirect_to edit_farm_path(@farm)    
  end

  def search
    @farms = Farm.where(nil)
    filtering_params(params).each do |key, value|
      @farms = @farms.public_send(key, value) if value.present?
    end
  end

  def dismiss_order
    @farm = Farm.find(params[:id])
    @order = @farm.orders.find(params[:format])
    @farm.orders.delete(@order)
    redirect_to edit_farm_path(@farm)
  end

  def destroy
    @farm=Farm.find(params[:id])
    @farm.destroy
    redirect_to farms_path
  end

  private
    def farm_params
      params.require(:farm).permit(:id, :name, :email, :password, :password_confirmation, :location, :file,
      			           products_attributes: [:feature, :category, :name, :unit, :price, :quantity,
				   			 :description, :notes, :available, :id, :_destroy])
    end

    def filtering_params(params)
      params.slice(:name_search, :location_search)
    end

end
