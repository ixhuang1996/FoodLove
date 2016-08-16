class UserMailer < ApplicationMailer
  default from: 'notifications@foodlove.farm'
  
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to FoodLove')
  end

  def order_self(order)
    @order = order
    @buyer = Buyer.find(@order.buyer_id)
    attachments["order_#{Date.current}.xls"] = File.read(Rails.root.join('print', 'orders', "#{@buyer.name}_#{Date.current}.xls"))
    mail(to: @buyer.email, subject: "Your Order #{Date.current}")
  end

  def order_farm(products, order)
    @order = order
    @buyer = Buyer.find(@order.buyer_id)
    @products = products
    @farm = Farm.find(products[0].farm_id)
    attachments["#{@buyer.name}_order_#{Date.current}.xls"] = 
      File.read(Rails.root.join('print', 'orders', "#{@farm.name}_#{@buyer.name}_#{Date.current}.xls"))
    mail(to: @farm.email, subject: "Order from #{@buyer.name}")
  end

  def order_dist(dist, order)
    @dist = dist
    @order = order
    @buyer = Buyer.find(@order.buyer_id)
    attachments["#{@buyer.name}_order_#{Date.current}.xls"] =
      File.read(Rails.root.join('print', 'orders', "#{@dist.name}_#{@buyer.name}_#{Date.current}.xls"))
    mail(to: @dist.email, subject: "Order from #{@buyer.name}")
  end

  def notif(buyer, note, farm)
    @buyer = buyer
    @text = note
    @farm = farm
    mail(to: @buyer.email, subject: "Notification from #{@farm.name}")
  end

  def contact(message, name, email)
    @message = message
    @name = name
    @email = email
    mail(to: "mia@foodlove.farm", subject: "Contact Form from #{@name}")
    mail(to: "isabella@foodlove.farm", subject: "Contact Form from #{@name}")
  end

  def message_farm(to, from, message)
    @farm=to
    @from=from
    @message=message
    mail(to: @farm.email, subject: "Message from #{@from.name}")
  end

end
