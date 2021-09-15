# Calculate the price
# ProductCalculatePrice.new(price, vat, vat_included).net_price
class ProductCalculatePrice

  # initialize
  # price: the price to calculated (float)
  # vat: object with info which vat rate to apply (Vat object)
  # vat_included: is price including vat? (boolean)
  def initialize(price, vat, vat_included)
    @price = price
    @vat = vat
    @vat_included = vat_included
  end

  # return the net price (i.e. excluding vat)
  def net_price
    if @vat_included
      gross_price - vat_sum
    else
      @price
    end
  end

  # return the gross price (i.e. including vat)
  def gross_price
    if @vat_included
      @price
    else
      net_price + vat_sum
    end
  end

  # calulate the vat sum
  def vat_sum
    val = 0

    # vat is included in price, i.e. net price = price / (1 + vat.value)
    if @vat_included && @vat.value != 0
      val = @price - (@price / (1 + @vat.value))
    # vat is not included in price, i.e. net_price = price * vat.value
    else
      val = @price * vat_rate
    end

    return val
  end

  # get the vat rate of vat object
  def vat_rate
    @vat.value.to_f || 0
  end


end
