require 'csv'
require 'erb'
require 'date'

def clean_regdate(regdate)
  DateTime.strptime(regdate,'%m/%d/%y %k:%M')
end

def tabulate_data(data,hash)
  if !hash[data].nil?
    hash[data] += 1
  else
    hash[data] = 1
  end
end

def format_hour(hour)
  if hour > 12
    "#{(hour-12).to_s.rjust(2,"0")}PM"
  else
    "#{hour.to_s.rjust(2,"0")}AM"
  end
end

def format_wday(wday)
  case wday
  when 0 then "Sun"
  when 1 then "Mon"
  when 2 then "Tue"
  when 3 then "Wed"
  when 4 then "Thu"
  when 5 then "Fri"
  when 6 then "Sat"
  end
end

def hash_sort(hash)
  hash.sort_by { |key, value| value }.reverse
end

def save_report(peak_hours, peak_days, form_report)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/targeting_report.html"

  File.open(filename,'w') do |file|
    file.puts form_report
  end
end

puts "Creating targeting report"

contents = CSV.open 'full_event_attendees.csv', headers: true, header_converters: :symbol
template_report = File.read "form_targeting_report.erb"
erb_template = ERB.new template_report

@peak_hours = Hash.new
@peak_wdays = Hash.new

contents.each do |row|
  reg_date = clean_regdate(row[:regdate])

  reg_hour = format_hour(reg_date.hour)
  reg_wday = format_wday(reg_date.wday)

  tabulate_data(reg_hour,@peak_hours)
  tabulate_data(reg_wday,@peak_wdays)
end

@peak_hours = hash_sort(@peak_hours)
@peak_wdays = hash_sort(@peak_wdays)

form_report = erb_template.result(binding)
save_report(@peak_hours, @peak_wdays, form_report)
