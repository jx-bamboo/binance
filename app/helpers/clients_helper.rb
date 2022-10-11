module ClientsHelper
    def get_platform num 
        return ["币安","火币"][num]
    end

    def get_web num 
        return ["binance.com","huobi.com"][num]
    end

end
