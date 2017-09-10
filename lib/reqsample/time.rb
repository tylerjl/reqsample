module ReqSample
  # Custom Time methods
  class Time < Time
    def within(center, limit)
      seconds_range = limit * 60 * 60
      (center - seconds_range) <= self && self <= (center + seconds_range)
    end
  end
end
