require_relative '../lib/quantum_ruby'

# In classical computing a control bit only affects the target bit
# These can also be done with a quantum circuit
# Circuit:
#   x ----- | C_NOT  | ----- x
#   y ----- |  GATE  | ----- y flipped
x = Qubit.new(0, 1) # the control bit, 1
y = Qubit.new(1, 0) # the target bit, 0
C_NOT_GATE.*(x, y).measure
# Since the control bit is set, we expect the target to flip
raise unless y == Qubit.new(0, 1)

# What is strange is that depending on how the qubits are entangled we can have
# the target bit toggling the control bit!
# Details can be read here:
#   https://en.wikipedia.org/wiki/Controlled_NOT_gate#Constructing_the_Bell_State_%7F'"`UNIQ--postMath-00000039-QINU`"'%7F
#   https://quantum.country/qcvc#the-controlled-not-gate

# Backwards control gate
# Circuit:
#   x ---| H    | -- | C_NOT  | -- | H    |---- x flipped
#   y ---| Gate | -- |  GATE  | -- | Gate |---- y
x = Qubit.new(1, 0) # the control bit, 1
y = Qubit.new(0, 1) # the target bit, 0
h_big = H_GATE.kronecker(H_GATE)
raise unless (h_big * (C_NOT_GATE * h_big)).*(x, y).measure
# control bit is fliped but target is the same!
raise unless x == Qubit.new(0, 1) && y == Qubit.new(0, 1)