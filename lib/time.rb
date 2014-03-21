NullTime = Time.now
def NullTime.to_usual
  ""
end

def NullTime.to_pretty
  "Sometime in the past, presumably"
end

class Time
  # nicked from parallel-flickr, because it's nice
  # straup/parallel-flickr/www/include/lib_flickr_dates.php
  def descriptive_hour
    case hour
    when 0..6 then "after midnight"
    when 6..8 then "in the wee small hours of the morning"
    when 8..12 then "in the morning"
    when 12..14 then "around noon"
    when 14..18 then "in the afternoon"
    when 18..20 then "in the evening"
    else "at night"
    end
  end

  def ordinal
    case day
    when 1, 21 then "st"
    when 2, 22 then "nd"
    else "th"
    end
  end

  def to_usual
    strftime("%FT%T%:z")
  end

  def to_pretty
    hour = descriptive_hour
    day = strftime("%A %B %-d") + ordinal + strftime(" %Y")
    "#{day}, #{hour}"
  end
end
