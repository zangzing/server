
100.times do

  capture_date = Time.now.to_i
  batch_number = 100
  thirty_years = 30 * 365 * 24 * 60 * 60

  timestamp = Time.now.to_f.to_s.gsub(".","").ljust(17,"0")


  pos = (capture_date + (batch_number * thirty_years)).to_s.rjust(13,"0") + timestamp


  puts pos + " ==> " + pos.to_i.to_s


end



