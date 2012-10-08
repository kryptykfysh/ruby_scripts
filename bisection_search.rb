# bisection_search.rb

balance = 999999
annual_interest_rate = 0.18

def set_monthly_payment_guess(upper_bound, lower_bound)
	(upper_bound + lower_bound) / 2.0
end

def calculate_remaining_balance(balance, monthly_interest, monthly_payment)
	test_balance = balance
	12.times do 
		after_payment = test_balance - monthly_payment
		test_balance = after_payment * (1 + monthly_interest)
	end
	return test_balance
end

monthly_interest_rate = annual_interest_rate / 12
lower_bound = balance / 12.0
upper_bound = balance * annual_interest_rate
test_balance = balance.to_f
monthly_payment_guess = set_monthly_payment_guess(upper_bound, lower_bound)

until test_balance.abs < 0.01
	puts "\nBalance: #{test_balance}"
	puts "Upper Bound: #{upper_bound}"
	puts "Lower Bound: #{lower_bound}"
	puts "Monthly Payment: #{monthly_payment_guess}"
	test_balance = balance.to_f
	test_balance = calculate_remaining_balance(test_balance, 
		monthly_interest_rate, monthly_payment_guess)
	if test_balance < 0
		upper_bound = monthly_payment_guess
	elsif test_balance > 0
		lower_bound = monthly_payment_guess
	end
	monthly_payment_guess = set_monthly_payment_guess(upper_bound, lower_bound)
end

puts "Lowest Monthly Payment: #{sprintf("%0.02f", monthly_payment_guess)}"