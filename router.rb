# TODO: implement the router of your app.
class Router
  def initialize
    @running = true
    @shopping = true
    @arr = [
      {
        watermelons: {
          3 => 6.99,
          5 => 8.99
        },
        pineapples: {
          2 => 9.95,
          5 => 16.95,
          8 => 24.95
        },
        rockmelons: {
          3 => 5.95,
          5 => 9.95,
          9 => 16.99
        },
        total: 0
      }
    ]
    @total = 0
    @cart = 0
  end

  def menu_manager
    puts ''
    puts 'What do you like to order ?'
    puts '1 - Watermellons'
    puts '2 - Pineapples'
    puts '3 - Rockmelons'
    puts '7 - Purchase My Cart'
    puts '8 - Stop and exit Fresho'
  end

  def order_manager(product)
    case product
    when 1 then puts 'How Many Watermellons?'
    when 2 then puts 'How Many Pineapples?'
    when 3 then puts 'How Many Rockmelons?'
    when 7 then shopping
    when 8 then stop
    else puts 'Please choose an option'
    end
  end

  def product_manager(action)
    case action
    when 1 then puts 'How Many Watermellons?'
    when 2 then puts 'How Many Pineapples?'
    when 3 then puts 'How Many Rockmelons?'
    when 8 then stop
    else puts 'Please choose an option'
    end
  end

  def qty_manager(action)
    case action
    when 1 then puts 'How Many Watermellons?'
    when 2 then puts 'How Many Pineapples?'
    when 3 then puts 'How Many Rockmelons?'
    when 8 then stop
    else puts 'Please choose an option'
    end
  end

  def run
    puts 'Welcome to Fresho Food'
    puts '           --           '
    puts '           --           '
    order_arr = %w[watermelons pineapples rockmelons]
    order = []
    while @running && @shopping

      menu_manager
      product = gets.chomp.to_i
      order_manager(product)
      next unless @running && @shopping

      product_item = order_arr[product - 1]
      qty = gets.chomp.to_i
      order_line = [qty, product_item]

      order << order_line
      print `clear`

      puts ' --               -- '
      puts ' --   You Cart    -- '
      puts ' --               -- '
      order.each { |line| puts "  - #{line[0]} x #{line[1]}" }

    end

    print `clear`
    puts ' --                   -- '
    puts ' Your Final Invoice      '
    puts ' --                   -- '
    order.each do |line|
      cart_line_item(item_builder(qty: line[0],
                                  product: line[1].to_sym,
                                  arr: @arr), @arr, @cart, qty)
    end
    total(@cart)

    puts ' --                   -- '
    puts 'Thankyou for using Fresho'
    puts ' --                   -- '
  end

  def rescue_qty(options = {})
    key_hash = Hash.new(0)

    user_qty = options[:qty]
    product =  options[:product]
    arr = options[:arr]
    key = arr.first[product].keys.sort.reverse.first
    arr_qty = user_qty.divmod(key)
    key_hash[key] = arr_qty.first
    key_hash
  end

  def remainder_possible(arr_qty, keys, _key)
    count = 0
    remainder = arr_qty[1]
    keys.each do |key|
      count += 1 if remainder.divmod(key)[1].zero?
    end
    count > 0
  end

  def item_builder(options = {})
    success_keys = []
    key_hash = Hash.new(0)
    user_qty = options[:qty]
    product =  options[:product]
    arr = options[:arr]

    keys = arr.first[product].keys.sort.reverse
    success_hash = {
      product => {
        success_keys: success_keys
      }
    }
    keys.each do |key|
      arr_qty = user_qty.divmod(key)
      ## can we make up the remainder from the biggest
      # cheapest qty ?
      if remainder_possible(arr_qty, keys, key)
        key_hash[key] = arr_qty[0]
        success_keys << key_hash
        user_qty -= key_hash.sum { |k, v| k * v }
        next unless user_qty.zero?

        success_hash[:fullfilled] = true
        break
      end
      next unless user_qty.zero?

      success_hash[:fullfilled] = true
      break
    end
    ## gets closest to user required
    if success_keys == []
      success_keys << rescue_qty(
        qty: options[:qty],
        product: options[:product],
        arr: options[:arr]
      )
      success_hash[:fullfilled] = false
    end

    success_hash
  end

  def cart_line_item(item_hash, product_array, cart, qty_user)
    @cart = cart

    line_items_arr = []
    arr = product_array
    sum = 0
    qty = item_hash.values.first[:success_keys]
                   .first.sum { |k, v| k * v }
    product = item_hash.keys.first.to_s.capitalize

    item_hash.values.first[:success_keys]
             .first
             .each_pair do |key, value|
      line_sum = (arr.first[product.downcase.to_sym][key] * value)
      line = "  - #{value} x #{key} Pack @ #{arr.first[product.downcase.to_sym][key]}"
      line_items_arr << line
      sum += line_sum
    end

    puts "#{qty} #{product}       $#{'%.2f' % sum.round(2)}"
    line_items_arr.each { |line| puts line }

    if item_hash[:fullfilled] == false
      puts '          **************                  '
      puts "Closest Available to #{qty_user} #{product.capitalize}"
      puts '                                         '
    end
    @cart += sum
  end

  def total(cart)
    @cart = cart
    puts '------------------------------------'
    puts "TOTAL               #{'%.2f' % @cart.round(2)}"
    puts '------------------------------------'
  end

  def stop
    @running = false
  end

  def shopping
    @shopping = false
  end
end
