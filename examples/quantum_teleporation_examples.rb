require_relative '../lib/quantum_ruby'

# Quantum Teleportation
# More details here:
#   https://quantum.country/teleportation
#   https://en.wikipedia.org/wiki/Quantum_teleportation#Non-technical_summary
#   https://cs.uwaterloo.ca/~watrous/LectureNotes/CPSC519.Winter2006/04.pdf

1_000.times do
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

  # Alice continues
  g = H_GATE.kronecker(I2).kronecker(I2) * C_NOT_GATE.kronecker(I2)
  s = g.*(a, s)

  # Alice measure her two qubits and sends classical bits to bob
  z, x = s.measure_partial(a, b)
  case [z, x].join.to_i(2)
  when 0
    raise unless a == Qubit.new(1, 0) && b == Qubit.new(1, 0)
  when 1
    raise unless a == Qubit.new(1, 0) && b == Qubit.new(0, 1)
  when 2
    raise unless a == Qubit.new(0, 1) && b == Qubit.new(1, 0)
  when 3
    raise unless a == Qubit.new(0, 1) && b == Qubit.new(0, 1)
  else
    raise
  end

  # depending on what bobs gets, he applies gates to his qubit
  # and is able to regain Alice’s 'a' qubit's original state instantly!
  c = X_GATE * c if x == 1
  c = Z_GATE * c if z == 1

  # Bob now knows Alice's original state. This is surprising, because Alice nor Bob
  # needed to EVER know the state prior and this information is "instantly" transferred
  # across any distance upon Alice's measurements
  raise unless a_dup == c
end
