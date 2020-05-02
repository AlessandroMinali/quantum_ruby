require "quantum_ruby/version"
require 'matrix'

# Overrides for base Ruby classes
class Matrix
  def kronecker(m)
    raise ErrOperationNotDefined, [__method__, self.class, m.class] unless m.is_a?(Matrix)

    a = Array.new(row_count * m.row_count) { Array.new(column_count * m.column_count) }

    count_ver = 0
    row_count.times do |i|
      count_hor = 0
      column_count.times do |j|
        m.row_count.times do |p|
          m.column_count.times do |q|
            a[i + p + count_ver][j + q + count_hor] = self[i, j] * m[p, q]
          end
        end
        count_hor += m.column_count - 1
      end
      count_ver += m.row_count - 1
    end
    self.class[*a]
  end
end

class Complex
  def round(digits)
    Complex(real.round(digits), imag.round(digits))
  end
end
# End of Overrides for base Ruby classes

ZERO_KET       = '|0>'
ONE_KET        = '|1>'
ADD_SYM        = ' + '
ADD_SYM_SQUISH = '+'
I_SYM          = 'i'

module ExceptionForQuantum
  class NormalizationConstraint < StandardError
    def initialize
      super('Normalizaton constraint failed. Amplitudes must equal 1')
    end
  end

  class ColumnMatrxiConstraint < StandardError
    def initalize
      super('Vector supplied must be a Matrix with a single column.')
    end
  end
end

module QuantumComplexPrinter
  refine Complex do
    def to_s
      out = ''
      out << real.round(3).to_s          if real.positive?
      out << ADD_SYM_SQUISH              if real.positive? && imag
      out << imag.round(3).to_s << I_SYM if imag
    end
  end
end

module QuantumVector
  include ExceptionForQuantum
  using QuantumComplexPrinter


  PRECISION = 14

  def state
    out = '['
    out << @vector[0, 0].to_s
    @vector.drop(1).each do |i|
      out << "\n " << i.to_s
    end
    out << ']'
  end

  def ==(other)
    @vector.map { |i| i.round(PRECISION) } == other.vector.map { |i| i.round(PRECISION) }
  end

  private

  def column_vector?
    raise ColumnMatrxiConstraint unless @vector.is_a?(Matrix) && (@vector.column_count == 1)
  end

  def normalized?
    raise NormalizationConstraint unless @vector.reduce(0) { |i, v| i + v.abs2 }.round(PRECISION) == 1
  end
end

class Qubit
  attr_reader :vector
  attr_accessor :entangled
  include QuantumVector
  using QuantumComplexPrinter

  ENTANGLED_WARNING = "Alert:  This qubit is entangled.\n\tPlease locate and measure the State\n\tthat contains this qubit's superposition."

  def initialize(zero, one)
    @vector = Matrix[[zero], [one]]
    column_vector?
    normalized?
  end

  def to_s
    return if entangled?

    first = el(0)
    last = el(1)

    out = ''
    out << first.to_s << ZERO_KET unless first.zero?
    out << ADD_SYM                unless first.zero? || last.zero?
    out << last.to_s << ONE_KET   unless last.zero?
    out
  end

  def state
    return(puts(ENTANGLED_WARNING)) if entangled?

    super
  end

  def measure
    if rand < @vector[0, 0].abs2
      @vector = [1, 0]
      0
    else
      @vector = [0, 1]
      1
    end
  end

  private

  def el(row)
    out = @vector[row, 0]
    out.is_a?(Float) || out.is_a?(Complex) ? out.round(PRECISION) : out
  end

  def vector=(array)
    @vector = Matrix.column_vector(array)
    normalized?
  end

  def entangled?
    if entangled
      puts ENTANGLED_WARNING
      true
    else
      false
    end
  end
end

class State
  attr_reader  :vector
  attr_reader  :qubits
  include QuantumVector

  def initialize(vector, *qubits)
    @vector = vector
    column_vector?
    normalized?

    @qubits = qubits.flatten.tap { |i| i.each { |j| j.entangled = true } }
  end

  def measure
    v = @vector.to_a
    # reset state
    @vector = Matrix.column_vector Array.new(@vector.row_count, 0)

    # "determine' 'winner'
    acc = 0
    out = nil
    secret = rand

    v.each_with_index do |probability, index|
      acc += probability[0].abs2
      if acc > secret
        out = index
        break
      end
    end

    # Update state
    @vector.send(:[]=, out, 0, 1)

    # Update each qubit
    out = out.to_s(2).rjust(size, '0')
    result = out.split('').map(&:to_i)
    @qubits.each_with_index do |qubit, index|
      qubit.send(:vector=, Array.new(2, 0).tap { |vector| vector[out[0].to_i] = 1 })
      out = out[1..-1]
    end
    freeze
    result
  end

  def measure_partial(qubit:)
    # find location of our desired qubit(s)
    qubit_ids = qubit.map { |i| @qubits.find_index { |j| j.hash == i .hash } }

    # collect probabilities for qubit(s) states
    sub_result = @vector.to_a.flatten.each_with_index.group_by do |_probability, index|
      qubit_ids.map do |id|
        index.to_s(2).rjust(size, '0')[id]
      end.join
    end

    # calculate final probabilities for qubit(s) state
    probabilities = sub_result.transform_values { |v| v.reduce(0) { |i, p| i + p[0].abs2 } }.values
    acc = 0
    out = nil
    secret = rand

    # "determine' 'winner'
    probabilities.each_with_index do |probability, index|
      acc += probability
      if acc > secret
        out = index
        break
      end
    end

    # Renormalize
    squared_sum_mag = Math.sqrt(probabilities[out])
    out = out.to_s(2).rjust(qubit.length, '0')
    result = out.split('').map(&:to_i)
    new_state = sub_result.fetch(out).map { |i| i[0] / squared_sum_mag }

    # Update each qubit
    @qubits.each_with_index do |q, i|
      q.entangled = false
      if qubit_ids.include?(i)
        q.send(:vector=, Array.new(2, 0).tap { |vector| vector[out[0].to_i] = 1 })
        out = out[1..-1]
      else
        q.send(:vector=, new_state)
      end
    end
    freeze
    result
  end

  private

  def size
    Math.log(@vector.row_count, 2)
  end
end

class Gate < Matrix
  # can take gate, qubit, or state
  def *(*args, scale: nil)
    if scale
      arg = begin
              args[0].vector
            rescue StandardError
              args[0]
            end
      diff = (arg.row_count / row_count)
      if diff > 1
        return case scale
               when :down
                 Gate[*kronecker(Matrix.identity(diff))].*(*args)
               when :up
                 Gate[*Matrix.identity(diff).kronecker(self)].*(*args)
               end
      end
    end

    case args[0]
    when State, Qubit
      qubits = []
      args = args.map do |i|
        qubits << (i.is_a?(Qubit) ? i : i.qubits)
        i.vector
      end.reduce(:kronecker)
      State.new(super(args), qubits)
    else
      super(*args)
    end
  end
end

I2 = Gate.identity(2)
X_GATE = Gate[[0, 1], [1, 0]]
Y_GATE = Gate[[0, -1i], [1i, 0]]
Z_GATE = Gate[[1, 0], [0, -1]]
H_GATE = 1 / Math.sqrt(2) * Gate[[1, 1], [1, -1]]
T_GATE = Gate[[1, 0], [0, Math::E**((1i * Math::PI) / 4)]]
C_NOT_GATE = Gate[[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0]]
SWAP_GATE = Gate[[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]]
TOFFOLI_GATE = Gate[[1, 0, 0, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 0, 0, 1], [0, 0, 0, 0, 0, 0, 1, 0]]
