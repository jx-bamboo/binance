require 'binance_api'

class ClientsController < ApplicationController
  before_action :authenticate_user!
  # before_action :check_two_auth, except: %i[two_deal two]
  before_action :set_client, only: %i[ show edit update destroy]
  before_action :get_side_user, only: %i[index control vip two_auth new]
	skip_before_action :verify_authenticity_token, :only => [:cancle_order]
  require "rqrcode"
  require 'rest-client'

  # GET /clients or /clients.json
  def index
    logger.info "=========== controller ============"
  #   rest_client = BinanceAPI::REST.new
		# @pbtc = rest_client.ticker_price('BTCUSDT').value[:price]
		# @pbnb = rest_client.ticker_price('BNBUSDT').value[:price]
		# @pcake = rest_client.ticker_price('CAKEUSDT').value[:price]
		# @pdot = rest_client.ticker_price('DOTUSDT').value[:price]
  end

  # GET /clients/1 or /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients or /clients.json
  def create
    @client = current_user.clients.new(client_params)

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: "Client was successfully created." }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: "Client was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def control
    logger.info "---------- customer center ----------"

    user_account = Client.find(params[:format])
    @name = user_account.name
    @client_id = user_account.id
    get_user_key_sign user_account
    # @my_assets = @rest_client.account.value[:balances]

    @my_assets = [{:asset=>"BTC", :free=>"0.40200000", :locked=>"0.00000000"},{:asset=>"LTC", :free=>"0.00000000", :locked=>"0.00000000"},{:asset=>"ETH", :free=>"0.00050000", :locked=>"0.00000000"},{:asset=>"NEO", :free=>"0.00000000", :locked=>"0.00000000"},{:asset=>"BNB", :free=>"0.00000772", :locked=>"0.00000000"}]
		@open_order = [{"symbol":"CAKEUSDT","orderId":304386399,"orderListId":-1,"clientOrderId":"ios_704b002f280b4b489cf35d53a38e95dd","price":"20.00000000","origQty":"3.22000000","executedQty":"0.00000000","cummulativeQuoteQty":"0.00000000","status":"NEW","timeInForce":"GTC","type":"LIMIT","side":"SELL","stopPrice":"0.00000000","icebergQty":"0.00000000","time":1635773056219,"updateTime":1635773056219,"isWorking":true,"origQuoteOrderQty":"0.00000000"},{"symbol":"CAKEUSDT","orderId":304386415,"orderListId":-1,"clientOrderId":"ios_50de85f73dc448dab697652e8ee16184","price":"19.98000000","origQty":"2.42000000","executedQty":"0.00000000","cummulativeQuoteQty":"0.00000000","status":"NEW","timeInForce":"GTC","type":"LIMIT","side":"SELL","stopPrice":"0.00000000","icebergQty":"0.00000000","time":1635773061440,"updateTime":1635773061440,"isWorking":true,"origQuoteOrderQty":"0.00000000"},{"symbol":"CAKEUSDT","orderId":304386469,"orderListId":-1,"clientOrderId":"ios_38987707f8b34ca09498ae636fd02472","price":"19.95000000","origQty":"1.81000000","executedQty":"0.00000000","cummulativeQuoteQty":"0.00000000","status":"NEW","timeInForce":"GTC","type":"LIMIT","side":"SELL","stopPrice":"0.00000000","icebergQty":"0.00000000","time":1635773066675,"updateTime":1635773066675,"isWorking":true,"origQuoteOrderQty":"0.00000000"}]
		
		# open_order = get_open_orders(user_account.secret_key, user_account.public_key)
		# @open_order = JSON.parse(open_order)
		logger.info "======== #{@open_order} ========"

  end

  # description: entrust method
  # params: stype, coin
  def get_control
    logger.info "---- ready ----"
    @stype_coin = params[:entrust].split("_") if params[:entrust].present?
  end

  # description: recive entrust
  # params: buy||sale, coinname, coinprice, coinnumber
  def post_control
    user_account = Client.find(params[:client_id].to_i)

    get_user_key_sign user_account
    st = 1
    if params[:buy].present?
      logger.info "---- buy ----"
      rc = @rest_client.order(params[:buy], 'BUY', 'LIMIT', params[:number], price: params[:price], time_in_force: 'GTC')

    elsif params[:sale].present?
      logger.info "---- sale ----"
      rc = @rest_client.order(params[:sale], 'SELL', 'LIMIT', params[:number], price: params[:price], time_in_force: 'GTC')
    else
      st = 0
    end
    logger.info rc.value || "******** error *******"
    render html: back_entrust_status(st).html_safe
  end
	
	def cancle_order
		logger.info "******** 取消一个订单 #{params[:symble]}, #{params[:order_id]} ********"
		user_account = Client.find(params[:client_id].to_i)
		get_user_key_sign user_account
		rc = @rest_client.cancel_order(params[:symble].to_s, order_id: params[:order_id].to_s)
		
		logger.info "******** #{rc.value} ********"
		render plain: 'ok'
		
	end
  
  def cancle_all_order
		user_account = Client.find(params[:format])
		get_user_key_sign user_account
		coin = params[:ex].upcase
		rc = @rest_client.open_orders(coin)
		logger.info rc.value || "******** cancle order error *******"
		redirect_to control_clients_path(user_account)
  end

  # def two_auth
  #   if current_user.int1.blank?
  #     url = "https://chain-ytbox.dbchain.cloud/relay/dbchain/oracle/user/get_secrect_key"
  #     payload = {
  #       "organization_id" => "dubian",
  #       "user_id" => current_user.email
  #     }
  #
  #     req = RestClient.post url, payload, {content_type: :json, accept: :json}
  #     rjson = JSON.parse(req)
  #     @img = rjson["qrcode_url_base64"]
  #     # @png = Base64.decode64(@img)
  #     @secret = rjson["secret_key"]
  #   end
  # end

  # def deal_two_auth
  #   if request.post?
  #     url = "https://chain-ytbox.dbchain.cloud/relay/dbchain/oracle/user/comform"
  #     payload = {
  #       "organization_id" => "dubian",
  #       "user_id" => current_user.email,
  #       "state" => Time.now.to_i,
  #       "verify_code" => params[:code]
  #     }
  #     req = RestClient.post url, payload, {content_type: :json, accept: :json}
  #     rjson = JSON.parse(req)
  #     if rjson["result"] == "success"
  #       current_user.int1 = 1
  #       respond_to do |format|
  #         if current_user.save
  #           format.html { redirect_to two_auth_clients_path, notice: "Authentication was successfully opented." }
  #           format.json { render :show, status: :created, location: @client }
  #         end
  #       end
  #     else
  #       redirect_to two_auth_clients_path, notice: "Authentication was wrong."
  #     end
  #   else
  #     url = "https://chain-ytbox.dbchain.cloud/relay/dbchain/oracle/user/destroy"
  #     payload = {
  #       "organization_id" => "dubian",
  #       "user_id" => current_user.email,
  #       "state" => Time.now.to_i
  #     }
  #     req = RestClient.post url, payload, {content_type: :json, accept: :json}
  #     rjson = JSON.parse(req)
  #     if rjson["result"] == "success"
  #       current_user.int1 = nil
  #       respond_to do |format|
  #         if current_user.save
  #           format.html { redirect_to two_auth_clients_path, notice: "Authentication was successfully closeed." }
  #           format.json { render :show, status: :created, location: @client }
  #         else
  #           format.html { render :new, status: :unprocessable_entity }
  #           format.json { render json: two_auth_clients_path.errors, status: :unprocessable_entity }
  #         end
  #       end
  #     end
  #   end
  # end

  # def two
  # end

  # def two_deal
  #   url = "https://chain-ytbox.dbchain.cloud/relay/dbchain/oracle/user/verify"
  #   payload = {
  #     "organization_id" => "dubian",
  #     "user_id" => current_user.email,
  #     "state" => Time.now.to_i,
  #     "verify_code" => params[:code]
  #   }
  #   req = RestClient.post url, payload, {content_type: :json, accept: :json}
  #   rjson = JSON.parse(req)
  #   respond_to do |f|
  #     if rjson["result"] == "success"
  #       # session[:code] = 1
  #       f.html { redirect_to clients_path, notice: "successfully" }
  #       f.json { render :show, status: :created, location: @client }
  #     else
  #       f.html { redirect_to two_clients_path, notice: "Authentication was wrong." }
  #       f.json { render :show, status: :created, location: @client }
  #     end
  #   end
  # end

  # def check_two_auth
  #   if session[:code] == 1
  #     redirect_to two_clients_path
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      #params.fetch(:client, {})
      params.require(:client).permit(:name,:platform,:public_key,:secret_key)
    end


    def back_entrust_status num
      case num
      when 1
          return '<div style="text-align:center;position:relative;top:50%;transform:translateY(-50%);color:#28a745;"><h1>委托成功</h1></div></div>'
      else
          return '<div style="text-align:center;position:relative;top:50%;transform:translateY(-50%);color:#bb2d3b;"><h1>网络故障</h1></div>'
      end
    end

		#获取用户的的操作钥匙
    def get_user_key_sign user_account
      @rest_client = BinanceAPI::REST.new
      @rest_client.api_key = user_account.public_key
      @rest_client.api_secret = user_account.secret_key
    end

		#获取左边侧边栏名下的托管用户
    def get_side_user
      @clients = current_user.clients.select(:name,:id)
    end

    def check_vip
      redirect_to vip_clients_path if current_user.int1 == nil
    end
	
	def get_open_orders(secret_key,api_key,options = {})
	  recv_window = options.delete(:recv_window) || BinanceAPI.recv_window
	  timestamp = options.delete(:timestamp) || Time.now

	  params = {
		  recvWindow: recv_window,
		  timestamp: timestamp.to_i * 1000 # to milliseconds
	  }

	  response = RestClient.get "https://api2.binance.com/api/v3/openOrders",params: params_with_signature(params, secret_key),'X-MBX-APIKEY' => api_key
		return response
	end
	
	def params_with_signature(params, secret)
	  params = params.reject { |_k, v| v.nil? }
	  query_string = URI.encode_www_form(params)
	  signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, query_string)
	  params = params.merge(signature: signature)
	end

end
