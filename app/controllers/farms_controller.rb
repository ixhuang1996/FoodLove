class FarmsController < ApplicationController

  def index
    @farms=Farm.all
  end

  def show
    @farm=Farm.find(params[:id])
    @products = @farm.products
    @categories = Array.new
    @cat = nil
    @products.sort_by{|p| p.category}.each do |pro|
      if pro.category != @cat
        @categories.push pro.category.tr(" ", "_")
        @cat = pro.category
      end
    end    
  end

  def new
    @farm=Farm.new
  end

  def edit
    @user=User.find(params[:id])
    @farm=Farm.find(params[:id])
    @orders=@farm.orders
    @notifs=@farm.notifications
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
      flash[:notice] = "Account successfully updated!"
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
    send_upload_notif
    redirect_to farm_products_path(@farm)

  end

  def sendnotif
    @farm = Farm.find(params[:id])
    
    #send email to each buyer and distributor
    Buyer.all.each do |b|	
      if b.farms.exists?(@farm)
        UserMailer.notif(b,params[:notification][:notif],@farm).deliver_now
      end
    end

    Distributor.all.each do |d|
      if d.farms.exists?(@farm)
        UserMailer.notif(d,params[:notification][:notif],@farm).deliver_now
      end
    end

    #create notification object
    @farm.notifications.create(notif: params[:notification][:notif])

    redirect_to edit_farm_path(@farm)    
  end

  def dismiss_notif
    @farm = Farm.find(params[:id])
    @farm.notifications.delete(params[:format])
    redirect_to edit_farm_path(@farm)
  end

  def search
    @farms = Farm.where(nil)
    filtering_params(params).each do |key, value|
      @farms = @farms.public_send(key, value) if value.present?
    end
    @farms = @farms.sort_by{|f| f.distance_to(current_user) }
  end

  def sample
    send_file Rails.root.join('print', "foodlove_upload_template.xls")
  end

  def print
    @farm=Farm.find(params[:id])   

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    
    header_f = Spreadsheet::Format.new :weight => :bold
    
    money_f = Spreadsheet::Format.new :number_format => '$#,##0.00',
    	          		      :align => :left

    sheet.column(3).default_format = money_f

    i=0
    sheet.row(i).push @farm.name, Date.current
    i+=2
    sheet.row(i).push 'Category', 'Item', 'Unit', 'Price', 'Quantity', 'Description', 'Notes'
    sheet.row(i).default_format = header_f
    i+=1    

    @farm.products.sort_by{|p| [p.category, p.name.downcase, p.price]}.each do |product|
      if product.available?
      	 if product.name != sheet.row(i-1)[0] && sheet.row(i-1)[0] != "Category"
	   i+=1
	 end
        sheet.row(i).push product.category, product.name, product.unit, product.price, 
			  product.quantity, product.description, product.notes
	i+=1
      end
    end
    
    book.write Rails.root.join('print',"#{@farm.name}_#{Date.current}.xls")
    send_file Rails.root.join('print', "#{@farm.name}_#{Date.current}.xls")    
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

  def message
    @farm = Farm.find(params[:id])
    UserMailer.message_send(@farm, User.find(params[:message][:user]), params[:message][:message]).deliver_now
    flash[:notice]="Your message has been sent."
    redirect_to farm_path(@farm)
  end

  def compile_orders
    @farm = Farm.find(params[:id])
    @orders = @farm.orders

    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    i=0

    bold_f = Spreadsheet::Format.new :weight => :bold
    
    #header
    sheet.row(i).push 'Compiled Orders', "#{Date.current}"
    sheet.row(i).default_format=bold_f
    sheet.row(i+2).push 'Buyer', 'Product', 'Unit', 'Quantity'
    sheet.row(i+2).default_format=bold_f
    i+=3

    #print each order
    @orders.each do |o|
      if o.buyer_id != nil && o.placed != nil && DateTime.now.days_ago(7) < o.placed
        o.products.each do |p|
          sheet.row(i).push Buyer.find(o.buyer_id).name, p.name, p.unit, o.quantities.find_by(product_id: p.id).quant
	  i+=1
        end
      end
    end

    book.write Rails.root.join('print', "#{@farm.name}_orders_#{Date.current}.xls")
    send_file Rails.root.join('print', "#{@farm.name}_orders_#{Date.current}.xls")
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

    def send_upload_notif
      @farm.notifications.create(notif: "We just uploaded a new availability list.")
    end

end
