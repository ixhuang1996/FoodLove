class BuyersController < ApplicationController

  def index
    @buyers=Buyer.all
  end

  def show
    @buyer=Buyer.find(params[:id])
  end
  
  def new
    @buyer=Buyer.new
  end
   
  def edit
    @buyer=Buyer.find(params[:id])
    @farms=Farm.all
    @myfarms = @buyer.farms
    @dists = Distributor.all
    @mydists = @buyer.distributors
  end
  
  def create
    @buyer=Buyer.new(params[:user])
    if @buyer.save
      redirect_to @buyer
    else
      render User.new
    end
  end

  def update
    @buyer=Buyer.find(params[:id])
    if @buyer.update()
      redirect_to @buyer
    else
      render 'edit'
    end
  end

  def destroy
    @buyer=Buyer.find(params[:id])
    @buyer.destroy
    redirect_to buyers_path
  end

  def add_farm
    @buyer = Buyer.find(params[:id])
    @farms = Farm.all
  end

  def new_farm
    @buyer = Buyer.find(params[:id])
    @buyer.farms.push(Farm.find(params[:format]))
    redirect_to edit_buyer_path(@buyer)
  end

  def remove_farm
    @buyer = Buyer.find(params[:id])
    @buyer.farms.delete(Farm.find(params[:format]))
    redirect_to edit_buyer_path(@buyer)
  end

  def add_dist
    @buyer = Buyer.find(params[:id])
    @dists = Distributor.all
  end

  def new_dist
    @buyer = Buyer.find(params[:id])
    @buyer.distributors.push(Distributor.find(params[:format]))
    redirect_to edit_buyer_path(@buyer)
  end

  def remove_dist
    @buyer = Buyer.find(params[:id])
    @buyer.distributors.delete(Distributor.find(params[:format]))
    redirect_to edit_buyer_path(@buyer)
  end

end
