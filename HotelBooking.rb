require 'date'


class Room
  # Constants used in Room class
  # Constant to store room types in the hotel.
  ROOM_TYPE_MAP = {:delux => 1,:luxury => 2,:suite => 3,:presidential => 4}.freeze
  ROOM_TYPE_MAP_INVERSE = ROOM_TYPE_MAP.invert.freeze
  
  # Static Configuration data is stored
  @@room_data = {1 => {:price => 7000,:info => "queen size bed",:all => []},2 => {:price => 8500, :info => "pool facing",:all => []},
               3 => {:price => 12000,:info => "king bed",:all => []},4 => {:price => 20000,:info => "royal", :all => []} }

  # Dynamic creation of setter and getter methods for data.
  # These methods can be used to change configuration values.
  # setter/getter for price, information, and Rooms for particular class {delux/luxary..}

  ROOM_TYPE_MAP.keys.each do |room_type|
    define_singleton_method("set_price_for_#{room_type}_room") do |price|
      @@room_data[ROOM_TYPE_MAP[room_type]][:price] = price
    end
    define_singleton_method("get_price_for_#{room_type}_room") do
      @@room_data[ROOM_TYPE_MAP[room_type]][:price]
    end
    define_singleton_method("set_info_for_#{room_type}_room") do |info|
      @@room_data[ROOM_TYPE_MAP[room_type]][:info] = info
    end
    define_singleton_method("get_info_for_#{room_type}_room") do
      @@room_data[ROOM_TYPE_MAP[room_type]][:info]
    end
    define_singleton_method("set_room_numnbers_for_#{room_type}_room") do |rooms|
      @@room_data[ROOM_TYPE_MAP[room_type]][:all] = rooms
    end
    define_singleton_method("get_room_numnbers_for_#{room_type}_room") do
      @@room_data[ROOM_TYPE_MAP[room_type]][:all]
    end
  end

# method to initialize rooms based on class of rooms. 
  def self.set_room_number_for_all(params)
    ROOM_TYPE_MAP.keys.each do |room_type|
      send("set_room_numnbers_for_#{room_type}_room",params[room_type])
    end
  end

# methods to calculate total amount to chrge for booking.
# Date:: 12/08/2014
#
# <b>Expects</b>
# * <b>room_type</b><em>(Symbol)</em> Room Type
# * <b>no_of_days</b><em>(Integer)</em> Number of Days
#
# <b>Returns</b>
# * final_cost <em>(Integer)</em> Final amout to charge
  def self.get_total_amount(room_type, no_of_days)
  	final_cost = 0
  	case room_type
	when :delux
		final_cost = no_of_days * get_price_for_delux_room
	when :luxury
		final_cost = no_of_days * get_price_for_luxury_room
	when :suite
		final_cost = no_of_days * get_price_for_suite_room
	when :presidential
		final_cost = no_of_days * get_price_for_presidential_room
	end
	return final_cost
  end

end



# User class to represent user entity
# currently holds bare minimum information about user
# Other information can be added.

class User
	def initialize(name)
		@name = name
	end

	def set_info
	end
end





# Booking Calendar holds the entries of booking in date-wise format

class BookingCalendar
  @@booking_entries = {}

  # getter methods which returns all current bookings.
  def self.get_booking_entries
    @@booking_entries
  end

# methods to booking entry in the booking calendar
# Date:: 12/08/2014
#
# <b>Expects</b>
# * <b>room_type</b><em>(Symbol)</em> Room Type
# * <b>user obj </b>(User object)</em> user
# * <b>start_date</b><em>(Date)</em> Start Date
# * <b>end_date</b><em>(Date)</em> End Date
#
# <b>Returns</b>
# * selected room <em>(Integer)</em> Allocated Room for the requested dates.

  def self.add_booking_entry(type, person, start_date, end_date)
		available_rooms = find_available_rooms(start_date,end_date)[type]
		return false unless available_rooms  # return if no rooms avialbe in the requested period.

		selected_room = available_rooms.first # Select first room from all avialbe ones.

		# Make entries in register for all dates requested. one entry for each date 
		# bookings =>{
			# :delux => {:date => {Room1 => user_obj, Room2 => user_obj},
			# :luxury => {:date => {Room1 => user_obj, Room2 => user_obj},
			# }
		# }

		start_date.to_date.upto(end_date.to_date) do |date|
			@@booking_entries[date.to_s] ||= {}
			(@@booking_entries[date.to_s][type] ||= {}).merge!(selected_room => person)
		end

		# return selected room
		return selected_room
	end


# methods to look for all alvialbe room in all catagories in particular time range.
# Date:: 12/08/2014
#
# <b>Expects</b>
# * <b>start_date</b><em>(Date)</em> Start Date
# * <b>end_date</b><em>(Date)</em> End Date
#
# <b>Returns</b>
# * available room <em>(Hash)</em> All availabel rooms in hash with toom type

	def self.find_available_rooms(start_date,end_date)
		d_available,l_available,s_available,p_available = Room.get_room_numnbers_for_delux_room ,Room.get_room_numnbers_for_luxury_room,Room.get_room_numnbers_for_suite_room,Room.get_room_numnbers_for_presidential_room
		start_date.to_date.upto(end_date.to_date) do |date|
			date = date.to_s
			Room::ROOM_TYPE_MAP.keys.each do |room_type|
				if @@booking_entries[date] && @@booking_entries[date][room_type]
					case room_type
					when :delux
						d_available -= @@booking_entries[date][room_type].keys
					when :luxury
						l_available -= @@booking_entries[date][room_type].keys
					when :suite
						s_available -= @@booking_entries[date][room_type].keys
					when :presidential
						p_available -= @@booking_entries[date][room_type].keys
					end
				end
			end
		end
		{:delux => d_available,:luxury => l_available,:suite=> s_available,:presidential => p_available}
	end

end
# BookingCalendar ends here ----------------------------------------------------------------------------



# to populate intilialition data in Rooms
params = {}
('A'..'D').each do |floor|
  # create delux rooms array and set in params
  (1..5).each do |room_no|
    (params[:delux] ||= []) << floor + room_no.to_s
  end

  # create luxry rooms array and set in params
  (6..10).each do |room_no|
    (params[:luxury] ||= [])<< floor + room_no.to_s
  end
end

# create suite rooms array and set in params
(11..20).each do |room_no|
  (params[:suite] ||= [])<< "D" + room_no.to_s
end
params[:suite] += ["E1","E2"]

# create presidential rooms array and set in params
(3..10).each do |room_no|
  (params[:presidential] ||= []) << "E" + room_no.to_s
end

# Initlialize rooms at once
Room.set_room_number_for_all(params)

# --------------------------------------room initializaiton ends here -----------------------------------

# main program start here.
begin 
	puts "Please specify guest name: "
	name = gets.chomp 
	user = User.new(name)

	puts "please specify the start date:(in yy-mm-dd)"
	start_date = gets
	start_date = Date.parse(start_date)
	
	puts "please specify the end date:(in yy-mm-dd)"
	end_date = gets 
	end_date = Date.parse(end_date)

	if (start_date >= (Date.today + (365/2)) || end_date >= (Date.today + (365/2)))
		puts "Booking allowed up to 6 months in advance! try agian"
		res = ''
		next 
	end
	
	booking_info = BookingCalendar.find_available_rooms(start_date, end_date)
	
	puts "Rooms Availability in the period specified : "

	booking_info.each do |k,v|
		puts "#{k} : [#{v.join(', ')}]"
	end
	
	# puts booking_info
	puts "Please specify the type of room, Possible values : [#{booking_info.keys.join(', ')}]"
	type = gets.chomp 
	result = BookingCalendar.add_booking_entry(type.to_sym, name, start_date, end_date)
	total_cost = Room.get_total_amount(type.to_sym, (end_date - start_date).to_i)

	if result
		puts "Room booked successfully.Room Nnmber is #{result} | Total Cost : #{total_cost} | Thank you."
	else
		puts "Selected room type not available please try again"
	end
	
	# puts BookingCalendar.get_booking_entries
	
	puts "Do you want to continue(Y/N)"
	res = gets 

end while res.chomp != 'N'