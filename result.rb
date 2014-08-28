def strip_or_self(str)
  str.strip! || str if str
end

$today = Time.now

$calendar = nil
$desc     = nil
$location = "\"\""
$hour     = 9
$minute    = 0
$day = $today.day
$month = $today.month
$year = $today.year
$all_day  = "false"
$alarm_to_set = []

$has_on_defined = false
$recurrence_to_set = []
$freq = 0
$rep  = 0

$hour_to = -1
$minute_to = 0

$multiplier = {}
$multiplier["m"] = 1
$multiplier["min"] = 1
$multiplier["minute"] = 1
$multiplier["minutes"] = 1
$multiplier["h"] = 60
$multiplier["hour"] = 60
$multiplier["hours"] = 60
$multiplier["d"] = 1440
$multiplier["day"] = 1440
$multiplier["days"] = 1440
$multiplier["w"] = 10080
$multiplier["week"] = 10080
$multiplier["weeks"] = 10080
$multiplier["month"] = 43200
$multiplier["months"] = 43200
$multiplier["year"] = 525600
$multiplier["years"] = 525600

$weeks = {}
$weeks["sun"] = 1
$weeks["sunday"] = 1
$weeks["mon"] = 2
$weeks["monday"] = 2
$weeks["tuesday"] = 3
$weeks["tue"] = 3
$weeks["wednesday"] = 4
$weeks["wed"] = 4
$weeks["thursday"] = 5
$weeks["thu"] = 5
$weeks["friday"] = 6
$weeks["fri"] = 6
$weeks["saturday"] = 7
$weeks["sat"] = 7

$months = {}
$months["jan"] = 1
$months["feb"] = 2
$months["mar"] = 3
$months["apr"] = 4
$months["may"] = 5
$months["jun"] = 6
$months["jul"] = 7
$months["aug"] = 8
$months["sep"] = 9
$months["oct"] = 10
$months["nov"] = 11
$months["dec"] = 12
$months["january"] = 1
$months["february"] = 2
$months["march"] = 3
$months["april"] = 4
$months["may"] = 5
$months["june"] = 6
$months["july"] = 7
$months["august"] = 8
$months["september"] = 9
$months["october"] = 10
$months["november"] = 11
$months["december"] = 12


def parse_cal(query)
  # Alarm
  if (query.index(" alarm "))
    list = query.split(" alarm ")
    alarms = strip_or_self(list[1])
    query = list[0]
    
    alarm_list = alarms.split(" ")
    if (alarm_list.size > 1)
      counter = "."
      alarm_list.each { |val|
        if (counter != ".")
          if (!$multiplier[val].nil?)
            new_alarm = counter * $multiplier[val]
            $alarm_to_set.push(new_alarm)
            counter = "."
          end
        else
          counter = val.to_i
        end
      }
    end
  end

  # Calendar Name
  if (query.index(" @")) 
    list = query.split(" @")
    $calendar = strip_or_self(list[1])
    query = list[0]
  end

  # Location 
  if (query.index(" in ")) 
    list = query.split(" in ")
    $location = strip_or_self(list[1])
    query = list[0]
  end

  # Repeat
  # Recurrence
  if (query.index(" every "))
    list = query.split(" every ")
    if (list[1])
      recurrencies = strip_or_self(list[1])
      query = list[0]
    
      recurrence_list = recurrencies.split(" ")
      if (recurrence_list.size > 0)
        counter = "."
        recurrence_list.each { |val|
          value = strip_or_self(val)
          value = value.downcase
      
          $recurrence_to_set.push(value)
        }
      end
    end
  end

  # Date
  # Check if "on" exists
  if (query.index(" on ")) 
    $has_on_defined = true
    list = query.split(" on ")
  
    # If month is defined
    if (list[1].index("\/"))
      list_d = list[1].split("\/")
      $day = list_d[0]
      $month = list_d[1]
    
      if (list_d.size > 2)
        $year = list_d[2]
        if ($year.size < 4)
          cur_year = $today.year.to_s
          $year = (cur_year[0].chr + cur_year[1].chr + $year.to_s).to_i
        end
      end
    else
      c_day = strip_or_self(list[1])
      c_day = c_day.downcase
      if (!$weeks[c_day].nil?)
        c_week = $today.wday
        c_add = ($weeks[c_day] - 1) - c_week
        if (c_add < 0)
          c_add = 7 + c_add
        end
        
        new_day = $today + (c_add * 86400)
        $day     = new_day.day
        $month   = new_day.month
        $year    = new_day.year
      else
        $day = c_day
      end
    end

    query = list[0]
  elsif (query.index(/ [tT]oday/)) 
    $has_on_defined = true
    list = query.split(/ [tT]oday/)
    query = list[0]
  elsif (query.index(" tomorrow")) 
    $has_on_defined = true
    list = query.split(" tomorrow")
    
    tomorrow = $today + 86400
    $day     = tomorrow.day
    $month   = tomorrow.month
    $year    = tomorrow.year
    
    query   = list[0]
  end
  
#   #Time - to
#   if (query.index(" to ")) 
#     list = query.split(" to ")
#     query = strip_or_self(list[0])
#     
#     $hour_to = list[1]
#     $minute_to = 0
# 
#     if ($hour_to.index(":"))
#       h_list = $hour_to.split(":")
#       $hour_to = h_list[0]
#       $minute_to = h_list[1]
#       
#       if ($minute_to.downcase.index("pm"))
#         min_list = $minute_to.split("pm")
#         $minute_to = strip_or_self(min_list[0])
#         if ($hour_to.to_i < 13)
#           $hour_to = ($hour_to.to_i + 12).to_s
#         end
#       end
#       
#       if ($minute_to.downcase.index("am"))
#         min_list = $minute_to.split("am")
#         $minute_to = strip_or_self(min_list[0])
#       end
#     else
#       if ($hour_to.downcase.index("pm"))
#         min_list = $hour_to.split("pm")
#         $hour_to = strip_or_self(min_list[0])
#         if ($hour_to.to_i < 13)
#           $hour_to = ($hour_to.to_i + 12).to_s
#         end
#       end
#       
#       if ($hour_to.downcase.index("am"))
#         min_list = $hour_to.split("am")
#         $hour_to = strip_or_self(min_list[0])
#       end
#     end
#   end
  
  # Time - at
  if (query.index(" at ")) 
    list = query.split(" at ")
    $desc = strip_or_self(list[0])
  
    $hour = list[1]
    $minute = 0

    if ($hour.index(":"))
      h_list = $hour.split(":")
      $hour = h_list[0]
      $minute = h_list[1]
      
      if ($minute.downcase.index("pm"))
        min_list = $minute.split("pm")
        $minute = strip_or_self(min_list[0])
        if ($hour.to_i < 13)
          $hour = ($hour.to_i + 12).to_s
        end
      end
      
      if ($minute.downcase.index("am"))
        min_list = $minute.split("am")
        $minute = strip_or_self(min_list[0])
      end
    else
      if ($hour.downcase.index("pm"))
        min_list = $hour.split("pm")
        $hour = strip_or_self(min_list[0])
        if ($hour.to_i < 13)
          $hour = ($hour.to_i + 12).to_s
        end
      end
      
      if ($hour.downcase.index("am"))
        min_list = $hour.split("am")
        $hour = strip_or_self(min_list[0])
      end
    end
  else
    $desc = query
    $all_day = "true"
  end
  
  if ($recurrence_to_set.size > 0)
    # se tem dia
    if ($recurrence_to_set.include?("day"))
      $freq = "DAILY;"
    elsif ($recurrence_to_set.include?("week"))
      $freq = "WEEKLY;"
    elsif ($recurrence_to_set.include?("month"))
      $freq = "MONTHLY;"
    elsif ($recurrence_to_set.include?("year"))
      $freq = "YEARLY;"
    else
      # procura por um numero (representa um dia)
      day_list = []
      is_first = true
      $recurrence_to_set.each { |val|
        if (val.to_i > 0)
          if (is_first and not $has_on_defined)
            $day     = val
            is_first = false
          end
          day_list.push(val)
        end
      }
    
      if (day_list.size > 0)
        $freq = "MONTHLY;"
        $rep  = "BYMONTHDAY=" + day_list.join(",")
      else
        week_list = []
        is_first = true
        $recurrence_to_set.each { |val|
          # procura por semanas
          if ($weeks[val])
            if (is_first and not $has_on_defined)
              is_first = false

              c_week = $today.wday
              c_add = ($weeks[val] - 1) - c_week
              if (c_add < 0)
                c_add = 7 + c_add
              end
  
              new_day = $today + (c_add * 86400)
              $day     = new_day.day
              $month   = new_day.month
              $year    = new_day.year
            end
            value = val[0..1].upcase
            week_list.push(value)
          end
        }
    
        if (week_list.size > 0)
          $freq = "WEEKLY;"
          $rep  = "BYDAY=" + week_list.join(",")
        else
          month_list = []
          $recurrence_to_set.each { |val|
            # procura por meses
            if ($months[val])
              month_list.push($months[val])
            end
          }
      
          if (month_list.size > 0)
            $freq = "MONTHLY;"
            $rep  = "BYMONTH=" + month_list.join(",")
          end
        end
      end 
    end
  end
  
end

query = ARGV[0]
parse_cal(query)
subtitle = "Date: #{$day}/#{$month}/#{$year} - #{$hour}:" + ("%02d" % $minute)
if $location != "" 
  subtitle = subtitle + "   Location:#{$location}"
end

if $freq != 0
  freq_str = ""
  if ($freq == "DAILY;")
    freq_str = "daily"
  elsif ($freq == "WEEKLY;")
    freq_str = "weekly"
  elsif ($freq == "MONTHLY;")
    freq_str = "monthly"
  elsif ($freq == "YEARLY;")
    freq_str = "yearly"
  elsif ($freq == "DAILY;")
    freq_str = "daily"
  end
  subtitle = subtitle + " - Repeat: " + freq_str
end
item = "<item uid=\"addcalendarevent\" arg=\"#{query}\" ><title>#{$desc}</title><subtitle>#{subtitle}</subtitle><icon>icon.png</icon></item>"

if ($alarm_to_set.size == 0)
  $alarm_to_set.push("at event time")
end

count = 1
$alarm_to_set.each { |val|
  item = item + "<item uid=\"alarm#{val}\" arg=\"\" valid=\"no\" ><title>Alarm #{count}</title><subtitle>#{val}</subtitle><icon>alarm.png</icon></item>"
  count = count + 1
}

puts "<?xml version=\"1.0\"?><items>#{item}</items>"