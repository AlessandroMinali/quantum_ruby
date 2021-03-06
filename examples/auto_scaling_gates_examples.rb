require_relative '../lib/quantum_ruby'

# Auto scale gates
# Sometimes we want to apply a gate to N-qubits that takes only takes less than N inputs
# To accomodate this we can scale the gatewith the identity matrix.
# This has the effect of taking in a larger input size but still only affecting less than N inputs
# More details here:
#   https://en.wikipedia.org/wiki/Quantum_logic_gate#Application_on_entangled_states

# Circuit:
#   Before scaling
#   x --- | H Gate | -- | C_NOT  | -- | H Gate | -
#   y ----------------- |  GATE  | ---------------
#
#   After scaling
#   x --- | H Gate | -- | C_NOT  | -- | H Gate  | -
#   y ----------------- |  GATE  | -- | I2 Gate | -
x = Qubit.new(1, 0)
y = Qubit.new(1, 0)
step_1 = H_GATE * x # single input
step_2 = C_NOT_GATE.*(step_1, y) # double input, so future gates must accept 2 qubits
raise unless H_GATE.*(step_2, scale: :down) == State.new(0.5 * Matrix[[1], [1], [1], [-1]])

# Circuit:
#   Before scaling
#   x --- | H Gate | -- | C_NOT  | ---------------
#   y ----------------- |  GATE  | -- | H Gate | -
#
#   After scaling
#   x --- | H Gate | -- | C_NOT  | -- | I2 Gate | -
#   y ----------------- |  GATE  | -- | H Gate  | -
x = Qubit.new(1, 0)
y = Qubit.new(1, 0)
step_1 = H_GATE * x # single input
step_2 = C_NOT_GATE.*(step_1, y) # double input, so future gates must accept 2 qubits
raise unless H_GATE.*(step_2, scale: :up) == State.new(0.5 * Matrix[[1], [1], [1], [-1]])
