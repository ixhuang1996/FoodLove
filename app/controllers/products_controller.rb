class ProductsController < ApplicationController
  def index
    @farm = Farm.find(params[:farm_id])
    @products = @farm.products
  end

  def search
    @products = Product.where(nil)
    filtering_params(params).each do |key, value|
      @products = @products.public_send(key, value) if value.present?
    end
  end

  def create
    @farm = Farm.find(params[:farm_id])
    @product = @farm.products.create(product_params)
    redirect_to farm_products_path(@farm)
  end

  def edit_all
    @farm = Farm.find(params[:farm_id])
    @products = @farm.Product.all
  end

  def update
    @farm = Farm.find(params[:farm_id])
    if params[:products] != nil
      Product.update(params[:products][:product].keys, params[:products][:product].values)
    else
      @product = @farm.products.update(params[:id], product_params)
    end
    redirect_to edit_farm_path(@farm)
  end  

  def update_all
    @farm = Farm.find(params[:farm_id])
    params['products'].keys.each do |id|
      @product=@farm.Product.find(id.to_i)
      @product.update_attributes(params['products'][id])
    end
    redirect_to edit_farm_path(@farm)
  end

  def destroy
    @farm = Farm.find(params[:farm_id])
    @product = @farm.products.find(params[:id])
    @product.destroy
    redirect_to farm_product_path(@farm)
  end

  def show
    @farm = Farm.find(params[:farm_id])
    @product = @farm.products.find(params[:id])

  end

  private
    def product_params
      params.require(:product).permit(:name,:unit,:price,:category,:available,:feature,
	                              :description,:notes,:quantity)
    end

    def filtering_params(params)
      params.slice(:name_search, :category_search, :farm_search, :name_or_cat)
    end

end