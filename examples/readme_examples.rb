require_relative '../lib/quantum_ruby'
# All the readme examples tested

# qubit_1 = Qubit.new(1, 0)
# qubit_1.measure # returns 0 bit
# qubit_2 = Qubit.new(0, 1)
# qubit_2.measure # returns 1 bit
qubit_1 = Qubit.new(1, 0)
raise unless qubit_1.measure.zero?
qubit_2 = Qubit.new(0, 1)
raise unless qubit_2.measure == 1

# # single qubit gate example (X_GATE ie. quantum NOT gate)
# qubit_1 = Qubit.new(0, 1) # equivalent to classical 1 bit
# state = X_GATE * qubit_1
# state.measure # returns 0 bit
# # multi qubit gate example (C_NOT_GATE ie. controlled NOT gate)
# control_qubit = Qubit.new(1, 0) # 0 bit
# target_qubit  = Qubit.new(0, 1) # 1 bit
# # note multi params syntax: "GATE.*(param1, param2, etc.)"
# state = C_NOT_GATE.*(control_qubit, target_qubit) 
# state.measure_partial(target_qubit) # return 1 bit since control is 0
# # again with control bit ON
# control_qubit = Qubit.new(0, 1) # 1 bit
# target_qubit  = Qubit.new(0, 1) # 1 bit
# state = C_NOT_GATE.*(control_qubit, target_qubit) 
# state.measure_partial(target_qubit) # return 0 bit since control is 1
# single qubit gate example (X_GATE ie. quantum NOT gate)
qubit_1 = Qubit.new(0, 1)
state = X_GATE * qubit_1
raise unless state.measure[0].zero?
control_qubit = Qubit.new(1, 0)
target_qubit  = Qubit.new(0, 1)
state = C_NOT_GATE.*(control_qubit, target_qubit) 
raise unless state.measure_partial(target_qubit)[0] == 1
# again with control bit ON
control_qubit = Qubit.new(0, 1) # 1 bit
target_qubit  = Qubit.new(0, 1) # 1 bit
state = C_NOT_GATE.*(control_qubit, target_qubit) 
raise unless state.measure_partial(target_qubit)[0].zero?

# x = Matrix[[0, 1], [1, 0]]
# y = Gate[[0, 1], [1, 0]]
x = Matrix[[0, 1], [1, 0]]
y = Gate[[0, 1], [1, 0]]

# Y_X_GATE = Y_GATE.kronecker(X_GATE)
Y_X_GATE = Y_GATE.kronecker(X_GATE)

# state = State.new(Matrix.column_vector([0, 0, 0, 1]))
# # H_GATE normally only works on 1 qubit ie. 2x1 matrix
# # the following will auto scale H_GATE with kronecker
# new_state = H_GATE.*(state, scale: :down)
state = State.new(Matrix.column_vector([0, 0, 0, 1]))
new_state = H_GATE.*(state, scale: :down)

# qubit_1 = Qubit.new(0, 1) # equivalent to classical 1 bit
# state = H_GATE * qubit_1
# state.measure # returns 0 bit or 1 bit with equal probability
qubit_1 = Qubit.new(0, 1)
state = H_GATE * qubit_1
raise unless state == State.new(Matrix.column_vector([1/Math.sqrt(2), -1/Math.sqrt(2)]))
