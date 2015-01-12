# If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. 
# The sum of these multiples is 23.
# Find the sum of all the multiples of 3 or 5 below 1000.

$q = 999


def start()
	group = []
	value = $q 

	while $q > 0 do
		if $q % 5 == 0 or $q % 3 == 0 
			group << value
			puts "the value is #{$q} & this group is divisible"
			$q -= 1
			value = $q
		else
			puts "the value is #{$q}"
			$q -= 1
			value = $q
		end
	end
	
	sum = group.inject(:+)
	puts "group consists of #{sum}"

end




start()
