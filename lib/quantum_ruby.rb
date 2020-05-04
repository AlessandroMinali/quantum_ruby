require 'quantum_ruby/version'
require 'matrix'

#
# Overrides for base ruby base classes
class Matrix
  #
  # Takes two arbitrary sized matrices resulting in a block matrix
  # according to the Kronecker Product
  # Details: https://en.wikipedia.org/wiki/Kronecker_product
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
# End of Overrides for base ruby base classes

ZERO_KET       = '|0>'.freeze
ONE_KET        = '|1>'.freeze
ADD_SYM        = ' + '.freeze
ADD_SYM_SQUISH = '+'.freeze
I_SYM          = 'i'.freeze

module ExceptionForQuantum
  class NormalizationConstraint < StandardError
    def initialize
      super('Normalization constraint failed. Sum of squared amplitudes must equal 1')
    end
  end

  class ColumnMatrxiConstraint < StandardError
    def initialize
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

#
# Contains helper functions for Qubit and State objects
module QuantumVector
  include ExceptionForQuantum
  using QuantumComplexPrinter

  PRECISION = 14

  def ==(other)
    @vector.map { |i| i.round(PRECISION) } == other.vector.map { |i| i.round(PRECISION) }
  end

  def state
    out = '['
    out << @vector[0, 0].to_s
    @vector.drop(1).each do |i|
      out << "\n " << i.to_s
    end
    out << ']'
  end

  private

  #
  # Qubit and State vectors must be normalized so that the sum
  # of squared amplitudes is equal to 1. This is a probability constraints saying that probabilities
  # must sum to 1
  #   Qubit.new(1, 1) # fail
  #   Qubit.new(1, 0) # pass
  #   Qubit.new(1/Math.sqrt(2), 1/Math.sqrt(2)) # pass
  def normalized?
    raise NormalizationConstraint unless @vector.reduce(0) { |i, v| i + v.abs2 }.round(PRECISION) == 1
  end
end

#
# The +Qubit+ class represents quantum bit. They are stored a 2-dimensional column vector.
# Qubits can be operated on via matrix multiplication or measurement.
class Qubit
  attr_reader   :vector
  attr_accessor :entangled
  include QuantumVector
  using QuantumComplexPrinter

  ENTANGLED_WARNING = "Alert:  This qubit is entangled.\n\tPlease locate and measure the State\n\tthat contains this qubit's superposition.".freeze

  #
  # Takes two values for the superposition of |0> and |1> respectively and store it in a Qubit
  # Values must obey the normalization constraint
  def initialize(zero, one)
    @vector = Matrix[[zero], [one]]
    normalized?
  end

  #
  # Measurement can only happen at the expense of information elsewhere in the system.
  # If two qubits are combined then their combined state becomes dependent so doing something to one
  # can affect the other. This applies both to further operations or measurement.
  # After measurement all related qubits' superpositions collapse to a classical interpretation, either 0 or 1
  #   Qubit.news(1, 0).to_s # 0, qubit remains the same
  #   Qubit.news(0, 1).to_s # 1, qubit remains the same
  #   Qubit.new(1/Math.sqrt(2), 1/Math.sqrt(2)) # either 0 or 1 and qubit superposition collapses
  #                                               to look like one the above qubits depending on the outcome
  def measure
    if rand < @vector[0, 0].abs2
      @vector = [1, 0]
      0
    else
      @vector = [0, 1]
      1
    end
  end

  #
  # Return the qubit's superposition as a pretty printed array
  #   Qubit.news(1, 0).state
  #   #   [1
  #   #    0]
  def state
    return if entangled?

    super
  end

  #
  # Returns the qubit's superposition in Bra-Ket notation
  #   Qubit.news(1, 0).to_s # 1|0>
  #   Qubit.news(0, 1).to_s # 1|1>
  #   Qubit.new(1/Math.sqrt(2), 1/Math.sqrt(2)) # 0.707|0> + 0.707|1>
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

  private

  def el(row)
    out = @vector[row, 0]
    out.is_a?(Float) || out.is_a?(Complex) ? out.round(PRECISION) : out
  end

  def entangled?
    puts ENTANGLED_WARNING if entangled
    entangled
  end

  def vector=(array)
    @vector = Matrix.column_vector(array)
    normalized?
  end
end

#
# The +State+ class represents a combination of qubits' superpositions. They are stored a 2**n-dimensional column vector where
# N is the numbers of qubits entangled.
# State is usually produce after the applications of gates to a number of qubits and is continually passed forward through
# the quantum circuit until a measurement is made.
# State can be operated on via matrix multiplication or measurement(partial or otherwise).
class State
  attr_reader  :vector
  attr_reader  :qubits
  include QuantumVector

  #
  # Takes a column matrix representing N qubits and the corresponding superposition
  # Values of the matrix must obey the normalization constraint
  # Additional takes references to the actual qubits so that they can be updated in the future
  def initialize(vector, *qubits)
    @vector = vector
    column_vector?
    normalized?

    @qubits = qubits.flatten.tap { |i| i.each { |j| j.entangled = true } }
  end

  #
  # Returns an array of bits representing the final state of all entangled qubits
  # All qubits are written with their new state and all superposition information is lost
  def measure
    measure_partial(@qubits)
  end

  #
  # Takes an array of qubits for which a measurement should be made
  # Returns an array of bits representing the final state of the requested qubits
  # All others qubits are written with a normalized state and all superposition information is lost
  def measure_partial(*qubit)
    # find location of our desired qubit(s)
    qubit_ids = qubit.map { |i| @qubits.find_index { |j| j.hash == i .hash } }.sort

    # collect probabilities for qubit(s) states
    sub_result = @vector.to_a.flatten.each_with_index.group_by do |_probability, index|
      qubit_ids.map do |id|
        index.to_s(2).rjust(size, '0')[id]
      end.join
    end

    # calculate final probabilities for qubit(s) state
    probabilities = sub_result.sort.to_h.transform_values { |v| v.reduce(0) { |i, p| i + p[0].abs2 } }.values

    # determine 'winner'
    acc = 0
    out = nil
    secret = rand
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
    new_state = sub_result.fetch(out).map { |i| i[0] / squared_sum_mag }

    # Update each qubit
    @qubits.each_with_index do |q, i|
      q.entangled = false
      if (index = qubit_ids.find_index(i))
        q.send(:vector=, Array.new(2, 0).tap { |vector| vector[out[index].to_i] = 1 })
      else
        q.send(:vector=, new_state)
      end
    end

    # State should no longer be used
    out.split('').map(&:to_i)
  end

  private

  def column_vector?
    raise ColumnMatrxiConstraint unless @vector.is_a?(Matrix) && (@vector.column_count == 1)
  end

  def size
    Math.log(@vector.row_count, 2)
  end
end

#
# The +Gate+ class represents quantum logic gates as matrices.
# These matrices should be square and unitary. It is up to the user to perform these checks if they want a custom gate.
# There are a number of gates provided in this gem:
  # X_GATE
  # Y_GATE
  # Z_GATE
  # H_GATE
  # T_GATE
  # C_NOT_GATE
  # SWAP_GATE
  # TOFFOLI_GATE
class Gate < Matrix
  #
  # Applies the 'effect' of the gate on the arguments.
  # The matrix operation on a gate can take multiple arguments but the dimensions must match according to the general
  # rules of matrix multiplication.
  #
  # Gates can be scaled if you want to only affect less than N qubits of a system. Scaling occurs either up or down. If both is desired
  # choose one direction and manually scale the other direction.
  # NOTE scaling is done brute force and may no be applicable to the needs of your circuit.
  # Refer to scaling examples for more details: https://github.com/AlessandroMinali/quantum_ruby/tree/master/examples/auto_scaling_gates_examples.rb
  #
  # Can take Gate, Qubit, or State
  # Results in a new Gate if supplied a Gate, otherwise returns a new State
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

X_GATE = Gate[
[0, 1],
[1, 0]]

Y_GATE = Gate[
[0, -1i],
[1i, 0]]

Z_GATE = Gate[
[1,  0],
[0, -1]]

H_GATE = 1 / Math.sqrt(2) * Gate[
[1,  1],
[1, -1]]

T_GATE = Gate[
[1,                              0],
[0, Math::E**((1i * Math::PI) / 4)]]

C_NOT_GATE = Gate[
[1, 0, 0, 0],
[0, 1, 0, 0],
[0, 0, 0, 1],
[0, 0, 1, 0]]

SWAP_GATE = Gate[
[1, 0, 0, 0],
[0, 0, 1, 0],
[0, 1, 0, 0],
[0, 0, 0, 1]]

TOFFOLI_GATE = Gate[
[1, 0, 0, 0, 0, 0, 0, 0],
[0, 1, 0, 0, 0, 0, 0, 0],
[0, 0, 1, 0, 0, 0, 0, 0],
[0, 0, 0, 1, 0, 0, 0, 0],
[0, 0, 0, 0, 1, 0, 0, 0],
[0, 0, 0, 0, 0, 1, 0, 0],
[0, 0, 0, 0, 0, 0, 0, 1],
[0, 0, 0, 0, 0, 0, 1, 0]]
