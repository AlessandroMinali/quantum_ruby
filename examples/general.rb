require 'quantum_ruby'

# should be added in upcoming ruby/matrix patch
class Matrix
  def adjoint
    conjugate.transpose
  end
end

# Matrix * test
a = Matrix[[1, 2, 3], [4, 5, 6]]
b = Matrix[[7, 8], [9, 10], [11, 12]]
raise unless a * b == Matrix[[58, 64], [139, 154]]

# Matrix * test
a = Matrix[[1, 2], [3, 4]]
b = Matrix[[2, 0], [1, 2]]
raise unless a * b == Matrix[[4, 4], [10, 8]]

# Kronecker product test
x = Matrix[[1, 2], [3, 4]]
y = Matrix[[0, 5], [6, 7]]
unless x.kronecker(y) == Matrix[[0, 5, 0, 10], [6, 7, 12, 14], [0, 15, 0, 20], [18, 21, 24, 28]]
  raise
end

x = Matrix[[1], [2]]
y = Matrix[[3], [4]]
raise unless x.kronecker(y) == Matrix[[3], [4], [6], [8]]

# 'Ket' visualization
x = Qubit.new(1, 0)
raise unless x.to_s == '1|0>'

# Complex number visualization
x = Qubit.new((1 + 1i) / 2, 1i / Math.sqrt(2))
raise unless x.to_s == '1/2+1/2i|0> + 0.707i|1>'
raise unless x.state == "[1/2+1/2i\n 0.707i]"

# NOT gate
z = Qubit.new(1, 0)
raise unless X_GATE * z == State.new(Matrix[[0], [1]])

# Uniform superposition gate
z = Qubit.new(1, 0)
raise unless H_GATE * z == State.new(Matrix[[1 / Math.sqrt(2)], [1 / Math.sqrt(2)]])

# Demonstrate gate reversibility
z = Qubit.new(0.6, 0.8)
raise unless H_GATE * H_GATE * z == State.new(Matrix[[0.6], [0.8]])

# Measuring
1_000.times do
  x = Qubit.new(1, 0).measure
  raise unless x.zero?

  x = Qubit.new(0, 1).measure
  raise unless x == 1

  # equal chance of result
  s = (H_GATE * Qubit.new(0, 1))
  case s.measure
  when 0
    raise unless s == State.new(Matrix[[1], [0]])
  when 1
    raise unless s == State.new(Matrix[[0], [1]])
  else
    raise
  end
end

x = Qubit.new(1 / Math.sqrt(2), 1 / Math.sqrt(2))
raise unless (H_GATE * x).measure.zero?

x = Qubit.new(1 / Math.sqrt(2), -1 / Math.sqrt(2))
raise unless (H_GATE * x).measure == 1

# Backwards control gate!
x = Qubit.new(1, 0)
y = Qubit.new(0, 1)
h_big = H_GATE.kronecker(H_GATE)
z = h_big * (C_NOT_GATE * h_big)
raise unless z.*(x, y) == State.new(Matrix[[0.0], [0.0], [0.0], [1.0]])

# Bell state
x = Qubit.new(1, 0)
y = Qubit.new(1, 0)
unless C_NOT_GATE.*(H_GATE * x, y) == State.new(Matrix[[0.7071067811865475], [0.0], [0.0], [0.7071067811865475]])
  raise
end

# Unitary inversion of gates
unless (C_NOT_GATE * H_GATE.kronecker(Matrix.identity(2))).adjoint == H_GATE.kronecker(Matrix.identity(2)) * C_NOT_GATE
  raise
end

# Auto scale gates
z = C_NOT_GATE.*(H_GATE * x, y)
unless H_GATE.*(z, scale: :down) == State.new(0.5 * Matrix[[1], [1], [1], [-1]])
  raise
end

# TOFFOLI_GATE test
unless TOFFOLI_GATE.*(Qubit.new(0, 1), Qubit.new(0, 1), Qubit.new(0, 1)) == State.new(Matrix.column_vector([0, 0, 0, 0, 0, 0, 1, 0]))
  raise
end

# Build a TOFFOLI_GATE from simple gates (C_NOT, H_GATE, and T_GATE's only)
T_3GATE_ADJOINT = I2.kronecker(I2).kronecker(T_GATE).adjoint
C_3NOT_GATE = Gate[*Matrix[[1, 0], [0, 0]].kronecker(I2.kronecker(I2)) + Matrix[[0, 0], [0, 1]].kronecker(I2.kronecker(X_GATE))]
unless TOFFOLI_GATE == C_NOT_GATE.*(T_GATE.kronecker(T_GATE.adjoint).*(C_NOT_GATE.kronecker(H_GATE).*(I2.kronecker(T_GATE).kronecker(T_GATE).*(C_3NOT_GATE.*(T_3GATE_ADJOINT.*(C_NOT_GATE.*(T_GATE.*(C_3NOT_GATE.*(T_3GATE_ADJOINT.*(C_NOT_GATE.*(I2.kronecker(I2).kronecker(H_GATE), scale: :up))), scale: :up), scale: :up))))), scale: :down), scale: :down).round
  raise
end

# Partial Measure
x = Qubit.new(0, 1)
y = Qubit.new(0, 1)
raise unless x == y

State.new(Matrix.column_vector([0, Math.sqrt(0.8), Math.sqrt(0.2), 0]), [x, y]).measure_partial(qubit: [y])
raise if x == y

x = Qubit.new(0, 1)
y = Qubit.new(0, 1)
z = Qubit.new(0, 1)
State.new(Matrix.column_vector([0, 0.5, 0.5, 0, 0, 0.5, 0.5, 0]), [x, y, z]).measure_partial(qubit: [y])
raise if (y == x) || (z == y)

# # Quantum Teleportation
100.times do
  # alice will teleport 'a' to bob
  a = Qubit.new(0, 1)
  b = Qubit.new(1, 0)
  c = Qubit.new(1, 0)
  # dup so we have copy of the original state to verify transportation.
  # In practice neither Alice nor Bob knows these values and our final check
  # cannot be preformed. Through the maths we can understand that this holds
  # regardless of not knowing initial values.
  a_dup = a.dup

  # first entangle 'b' and 'c'
  s = C_NOT_GATE.*(H_GATE * b, c)
  # bob takes 'c' far away

  # alice continues
  g = H_GATE.kronecker(I2).kronecker(I2) * C_NOT_GATE.kronecker(I2)
  s = g.*(a, s)
  # alice measure her two qubits and sends classical bits to bob
  z, x = s.measure_partial(qubit: [a, b])

  # depending on what bobs gets, he applies gates to his qubit
  # and is able to regain alice's 'a' qubit's original state instantly!
  c = X_GATE * c if x == 1
  c = Z_GATE * c if z == 1

  # p [z, x]
  # p a_dup, c
  raise unless a_dup == c
end
