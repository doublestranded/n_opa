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
      values.each_with_index.map do |v, j|
        if assignments.dig(j, i - 1) && assignments.dig(j, i - 1) == t
          0
        elsif j == 2
          v.nil? ? @matrix[i][t] : v + @matrix[i][t]
        elsif j == 1
          v.nil? ? 0 : (assignments[1][i].nil? ? v + @matrix[i][t-1] : v)
        else
          v.nil? || (assignments[0][-1] and assignments[0][-1] < t) ? 0 : v
        end
      end.each_with_index.max_by { |v, j| v }
    end

    def cost_compare(values, assignments, i, t)
      values.each_with_index.map do |v, j|
        if assignments.dig(j, i - 1) && assignments.dig(j, i - 1) == t
          Float::INFINITY
        elsif j == 2
          v.nil? ? @matrix[i][t] : v + @matrix[i][t]
        elsif j == 1
          v.nil? ? Float::INFINITY : (assignments[1][i].nil? ? v + @matrix[i][t-1] : v)
        else
          v.nil? || (assignments[0][-1] and assignments[0][-1] < t) ? Float::INFINITY : v
        end
      end.each_with_index.min_by { |v, j| v }
    end

    def base?(i, t)
      i == -1 ||
      t < i ||
      (t > ((@num_slots - 1) - (@num_items - (i + 1))))
    end

    def downStack(i, t)
      i.downto(0) do |j|
        @stack.push([j, t])
      end
    end

    def func(i, t)
      @memo[i][t] = [nil, []] if base?(i, t)
      return @memo[i][t] unless @memo.dig(i, t).nil?

      downStack(i, t)

      while @stack.any?
        i, t = @stack.last

        @memo[i-1][t] = [nil, []] if base?(i-1, t)
        @memo[i][t-1] = [nil, []] if base?(i, t-1)
        @memo[i-1][t-1] = [nil, []] if base?(i-1, t-1)


        unless @memo[i-1][t]
          downStack(i-1, t)
          next
        end

        unless @memo[i][t-1]
          downStack(i, t-1)
          next
        end

        unless @memo[i-1][t-1]
          downStack(i-1, t-1)
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
