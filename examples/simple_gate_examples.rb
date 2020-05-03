require_relative '../lib/quantum_ruby'

# NOT gate
# Circuit: 1|0> ----- X ------- 1|1> 
z = Qubit.new(1, 0)
raise unless X_GATE * z == State.new(Matrix[[0], [1]])

# Hadamard Gate ie. Uniform superposition gate
# Circuit: 1|0> ----- H ------- 1/sqrt(2)|0> + 1/sqrt(2)|1> 
z = Qubit.new(1, 0)
raise unless H_GATE * z == State.new(Matrix[[1 / Math.sqrt(2)], [1 / Math.sqrt(2)]])

# Demonstrate gate reversibility
# Since gates are unitary, applying them twice has the effect of reversing computation
# Circuit: 0.6|0> + 0.8|1> ---- H --- H --- 0.6|0> + 0.8|1>
z = Qubit.new(0.6, 0.8)
raise unless H_GATE * H_GATE * z == State.new(Matrix[[0.6], [0.8]])

# A mathimatical demonstration of gate reversibility ie. Unitary inversion of gates
# More details here:
#   https://en.wikipedia.org/wiki/Unitary_matrix
#   https://quantum.country/qcvc#what-does-it-mean-to-be-unitary
class Matrix; def adjoint; conjugate.transpose; end; end # helper function
raise unless (C_NOT_GATE * H_GATE.kronecker(Matrix.identity(2))).adjoint == H_GATE.kronecker(Matrix.identity(2)) * C_NOT_GATE
