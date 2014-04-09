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
            new_alarm = counter.to_s + " " + val + " before"
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

  # Date
  # Check if "on" exists
  if (query.index(" on ")) 
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
  elsif (query.index(" today")) 
    list = query.split(" today")
    query = list[0]
  elsif (query.index(" tomorrow")) 
    list = query.split(" tomorrow")
    
    tomorrow = $today + 86400
    $day     = tomorrow.day
    $month   = tomorrow.month
    $year    = tomorrow.year
    
    query   = list[0]
  end

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
    end
  else
    $desc = query
  end
  
end

query = ARGV[0]
parse_cal(query)
subtitle = "Date: #{$day}/#{$month}/#{$year} - #{$hour}:" + ("%02d" % $minute)
if $location != "" 
  subtitle = subtitle + "   Location:#{$location}"
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