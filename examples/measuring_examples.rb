require_relative '../lib/quantum_ruby'

# Measuring
1_000.times do
  x = Qubit.new(1, 0).measure
  raise unless x.zero?

  x = Qubit.new(0, 1).measure
  raise unless x == 1

  # H_GATE puts qubits into a uniform superposition
  s = (H_GATE * Qubit.new(0, 1))
  case s.measure[0]
  when 0
    raise unless s == State.new(Matrix[[1], [0]])
  when 1
    raise unless s == State.new(Matrix[[0], [1]])
  else
    raise
  end

  # Multi qubit systems update individual qubits to their new state after a measuerment occurs
  x = Qubit.new(1, 0)
  y = Qubit.new(0, 1)
  a = Array.new(4, 0)
  a[rand(4)] = 1
  r = State.new(Matrix.column_vector(a), [x, y]).measure.join.to_i(2)
  case r
  when 0
    raise unless x == Qubit.new(1, 0) && y == Qubit.new(1, 0)
  when 1
    raise unless x == Qubit.new(1, 0) && y == Qubit.new(0, 1)
  when 2
    raise unless x == Qubit.new(0, 1) && y == Qubit.new(1, 0)
  when 3
    raise unless x == Qubit.new(0, 1) && y == Qubit.new(0, 1)
  end

  x = Qubit.new(1, 0)
  y = Qubit.new(0, 1)
  z = Qubit.new(0, 1)
  a = Array.new(8, 0)
  a[rand(8)] = 1
  r = State.new(Matrix.column_vector(a), [x, y, z]).measure.join.to_i(2)
  case r
  when 0
    raise unless x == Qubit.new(1, 0) && y == Qubit.new(1, 0) && z == Qubit.new(1, 0)
  when 1
    raise unless x == Qubit.new(1, 0) && y == Qubit.new(1, 0) && z == Qubit.new(0, 1)
  when 2
    raise unless x == Qubit.new(1, 0) && y == Qubit.new(0, 1) && z == Qubit.new(1, 0)
  when 3
    raise unless x == Qubit.new(1, 0) && y == Qubit.new(0, 1) && z == Qubit.new(0, 1)
  when 4
    raise unless x == Qubit.new(0, 1) && y == Qubit.new(1, 0) && z == Qubit.new(1, 0)
  when 5
    raise unless x == Qubit.new(0, 1) && y == Qubit.new(1, 0) && z == Qubit.new(0, 1)
  when 6
    raise unless x == Qubit.new(0, 1) && y == Qubit.new(0, 1) && z == Qubit.new(1, 0)
  when 7
    raise unless x == Qubit.new(0, 1) && y == Qubit.new(0, 1) && z == Qubit.new(0, 1)
  end
end

# The following two show an example of reversing a previously applied Hadamard gate
# Circuit: 1/sqrt(2)|0> + 1/sqrt(2)|1> ----- H ------ 1|0>
x = Qubit.new(1 / Math.sqrt(2), 1 / Math.sqrt(2))
raise unless (H_GATE * x).measure[0].zero?

# Circuit: 1/sqrt(2)|0> + 1/sqrt(2)|1> ----- H ------ 1|1>
x = Qubit.new(1 / Math.sqrt(2), -1 / Math.sqrt(2))
raise unless (H_GATE * x).measure[0] == 1
