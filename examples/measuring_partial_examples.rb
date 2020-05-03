require_relative '../lib/quantum_ruby'
# Partial Measure


# After a partial measure qubits so no longer be equal
# One outcome is chosen for the desired qubit and all other qubits collapse to a normalized version of the 
# new state

# y is measured in a system of 2 qubits
x = Qubit.new(0, 1)
y = Qubit.new(0, 1)
raise unless x == y
State.new(Matrix.column_vector([0, Math.sqrt(0.8), Math.sqrt(0.2), 0]), [x, y]).measure_partial(y)
raise if x == y

# y is measure in a system of 3 qubits
x = Qubit.new(0, 1)
y = Qubit.new(0, 1)
z = Qubit.new(0, 1)
State.new(Matrix.column_vector([0, 0.5, 0.5, 0, 0, 0.5, 0.5, 0]), [x, y, z]).measure_partial(y)
raise if (y == x) || (z == y)

# The following shows all possibles outcomes, randomized and verified
# Can be a good way to understand partial measuring by considering the logics tables
# More information can be found at these resources:
#   https://cs.stackexchange.com/questions/71462/how-are-partial-measurements-performed-on-a-n-qubit-quantum-circuit
#   https://quantum.country/teleportation#background_partial_measurement
1_000.times do
  x = Qubit.new(0, 1)
  y = Qubit.new(0, 1)
  z = Qubit.new(0, 1)
  a = Array.new(8, 0)
  a[rand(8)] = 1
  r = State.new(Matrix.column_vector(a), [x, y, z]).measure_partial(y, z).join.to_i(2)
  case r
  when 0
    raise unless y == Qubit.new(1, 0) && z == Qubit.new(1, 0)
  when 1
    raise unless y == Qubit.new(1, 0) && z == Qubit.new(0, 1)
  when 2
    raise unless y == Qubit.new(0, 1) && z == Qubit.new(1, 0)
  when 3
    raise unless y == Qubit.new(0, 1) && z == Qubit.new(0, 1)
  else
    raise
  end

  i = Qubit.new(0, 1)
  y = Qubit.new(0, 1)
  z = Qubit.new(0, 1)
  a = Array.new(8, 0)
  a[rand(8)] = 1
  r = State.new(Matrix.column_vector(a), [y, z, i]).measure_partial(i, y).join.to_i(2)
  case r
  when 0
    raise unless y == Qubit.new(1, 0) && i == Qubit.new(1, 0)
  when 1
    raise unless y == Qubit.new(1, 0) && i == Qubit.new(0, 1)
  when 2
    raise unless y == Qubit.new(0, 1) && i == Qubit.new(1, 0)
  when 3
    raise unless y == Qubit.new(0, 1) && i == Qubit.new(0, 1)
  else
    raise
  end

  x = Qubit.new(0, 1)
  y = Qubit.new(0, 1)
  z = Qubit.new(0, 1)
  i = Qubit.new(0, 1)
  a = Array.new(16, 0)
  a[rand(16)] = 1
  r = State.new(Matrix.column_vector(a), [x, i, y, z]).measure_partial(x, y, z).join.to_i(2)
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