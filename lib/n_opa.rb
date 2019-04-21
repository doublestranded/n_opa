require "n_opa/version"

module NOpa
  class InputError < StandardError

  end

  class DynamicAlgorithm
    attr_reader :matrix
    attr_accessor :value,
                  :costs,
                  :assignments,
                  :base,
                  :memo

    def initialize(matrix, costs: false)
      @matrix = matrix.freeze

      @costs = costs

      validate_matrix

      @num_slots = @matrix[0].length
      @num_items = @matrix.length

      @memo = Hash[(-1...@matrix.length).to_a.zip(Array.new(@matrix.length + 1){ {} })]
      @assignments = []
      @stack = []
    end

    def compute
      @value, @assignments = func(@num_items - 1, @num_slots - 1)
    end

    private

    def validate_matrix
      if @matrix.flatten.any? { |v| v < 0 }
        raise InputError.new("Cannot have negative #{@costs ? 'costs' : 'profits'}")
      end

      unless @matrix.length > 0
        raise InputError.new('missing items to assign')
      end

      unless @matrix.all? { |i| i.class == Array }
        raise InputError.new('slot values per item should be arrays')
      end

      slots_length = @matrix.map { |i| i.length }.uniq

      if slots_length.length != 1
        raise InputError.new('must have the same number of slots per item')
      end

      # for injective only
      if slots_length[0] < @matrix.length
        raise InputError.new('Cannot have more items than slots')
      end
    end

    def profit_compare(values, assignments, i, t)
      a = if assignments[0][i - 1] and assignments[0][i - 1] == t
        0
      elsif values[0].nil? || (assignments[0][-1] and assignments[0][-1] < t)
        0
      else
        values[0]
      end

      b = if assignments[1][i - 1] and assignments[1][i - 1] == t
        0
      elsif values[1].nil?
        0
      elsif assignments[1][i].nil?
        values[1] + @matrix[i][t-1]
      else
        values[1]
      end

      c = if assignments[2][i - 1] and assignments[2][i - 1] == t
        0
      elsif values[2].nil?
        @matrix[i][t]
      else
        values[2] + @matrix[i][t]
      end

      if a >= b && a >= c
        return [a, 0]
      elsif b >= c
        return [b, 1]
      else
        return [c, 2]
      end
    end

    def cost_compare(values, assignments, i, t)
      a = if assignments[0][i - 1] and assignments[0][i - 1] == t
        Float::INFINITY
      elsif values[0].nil? || (assignments[0][-1] and assignments[0][-1] < t)
        Float::INFINITY
      else
        values[0]
      end

      b = if assignments[1][i - 1] and assignments[1][i - 1] == t
        Float::INFINITY
      elsif values[1].nil?
        Float::INFINITY
      elsif assignments[1][i].nil?
        values[1] + @matrix[i][t-1]
      else
        values[1]
      end

      c = if assignments[2][i - 1] and assignments[2][i - 1] == t
        Float::INFINITY
      elsif values[2].nil?
        @matrix[i][t]
      else
        values[2] + @matrix[i][t]
      end

      if a <= b && a <= c
        return [a, 0]
      elsif b <= c
        return [b, 1]
      else
        return [c, 2]
      end
    end

    def base?(i, t)
      i == -1 ||
      t < i ||
      (t > (@num_slots - @num_items  + i))
    end

    def func(i, t)
      return [nil, []] if base?(i, t)

      i.downto(0) do |j|
        @stack.push([j, t])
      end

      while @stack.any?
        i, t = @stack.last

        @memo[i-1][t] = [nil, []] if base?(i-1, t)
        @memo[i][t-1] = [nil, []] if base?(i, t-1)
        @memo[i-1][t-1] = [nil, []] if base?(i-1, t-1)

        unless @memo[i-1][t]
          @stack.push([i-1, t])
          next
        end

        unless @memo[i][t-1]
          @stack.push([i, t-1])
          next
        end

        unless @memo[i-1][t-1]
          @stack.push([i-1, t-1])
          next
        end

        @stack.pop

        a, x = @memo[i-1][t]
        b, y = @memo[i][t-1]
        c, z = @memo[i-1][t-1]

        v, k = if @costs
          cost_compare([a, b, c], [x, y, z], i, t)
        else
          profit_compare([a, b, c], [x, y, z], i, t)
        end

        _assignments = [x, y, z][k].dup

        if k == 1 && _assignments[i].nil?
          _assignments[i] = t - 1
        elsif k == 2
          _assignments[i] = t
        end

        @memo[i][t] = [v, _assignments]
      end

      @memo[i][t]
    end
  end
end
