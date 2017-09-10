module ReqSample
  # Custom Hash methods
  class Hash < Hash
    def self.weighted(h)
      sum = h.values.reduce(:+)
      Hash[h.map { |k, weight| [k, (Float weight) / sum] }]
    end

    def weighted_sample
      max_by do |_, weight|
        rand**(1.0 / weight)
      end.first
    end
  end
end
