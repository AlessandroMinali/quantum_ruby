require_relative '../lib/quantum_ruby'

# The Toffoli gate is a 3-qubit control gate (2 control, 1 target)
# We can build it from more basic quantum gates.
# We will use 3 gates to build this larger gate
#  1. Hadamard Gates (H_GATE)
#  2. Phase Shift Gates (T_GATE)
#  3. Control Gates (C_NOT_GATE)

# Helper function to perform adjoint of matrix
# More details here:
#   https://en.wikipedia.org/wiki/Conjugate_transpose   
class Matrix; def adjoint; conjugate.transpose; end; end 

# Special variations on our base gates
# T_GATEa is just the adjoint of a T_GATE
T_3GATE_ADJOINT = I2.kronecker(I2).kronecker(T_GATE).adjoint
# C_NOT gate that takes 3 inputs, uses the top as control, ignores the middle, and uses the bottom as target
# More details here:
#   https://quantumcomputing.stackexchange.com/questions/9614/how-to-interpret-a-4-qubit-quantum-circuit-as-a-matrix/9615#9615
#   https://quantumcomputing.stackexchange.com/questions/4252/how-to-derive-the-cnot-matrix-for-a-3-qbit-system-where-the-control-target-qbi
C_3NOT_GATE = Gate[*Matrix[[1, 0], [0, 0]].kronecker(I2.kronecker(I2)) + Matrix[[0, 0], [0, 1]].kronecker(I2.kronecker(X_GATE))]

# Assembly
# Circuit:
# -- | Toffoli | --    ----------------------------|C_3NOT|---------------------------|C_3NOT|----------|C_NOT|--|T_GATE|--|C_NOT|-
# -- | Gate    | -- == ----------|C_NOT|-----------|      |----------|C_NOT|----------|      |-|T_GATE|-|Gate |--|T_GATEa|-|Gate |-
# -- |         | --    -|H_GATE|-|Gate |-|T_GATEa|-|Gate  |-|T_GATE|-|Gate |-|T_GATE|-|Gate  |-|T_GATE|-|H_GATE|-------------------
raise unless TOFFOLI_GATE == C_NOT_GATE.*(T_GATE.kronecker(T_GATE.adjoint).*(C_NOT_GATE.kronecker(H_GATE).*(I2.kronecker(T_GATE).kronecker(T_GATE).*(C_3NOT_GATE.*(T_3GATE_ADJOINT.*(C_NOT_GATE.*(T_GATE.*(C_3NOT_GATE.*(T_3GATE_ADJOINT.*(C_NOT_GATE.*(I2.kronecker(I2).kronecker(H_GATE), scale: :up))), scale: :up), scale: :up))))), scale: :down), scale: :down).round