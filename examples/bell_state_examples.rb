require_relative '../lib/quantum_ruby'

# Bell state
# Maximally entangle qubits. This is one of the coolest results of quantum computing.
# Allows for things such as reverse control gates and quantum teleportation.
# More details here:
#   https://en.wikipedia.org/wiki/Bell_state#Applications
#   https://en.wikipedia.org/wiki/Controlled_NOT_gate#Constructing_the_Bell_State_%7F'"`UNIQ--postMath-00000039-QINU`"'%7F

# Circuit:
#   x ---| H    | -- | C_NOT  | -
#   y ---| Gate | -- |  GATE  | -

# My lay man understanding of maximal entanglement comes from the state that is produced here.
# Either the result can be 00 or 11 based on the probabilities. In this sense the qubits
# are completely dependent on one another for the outcome ie. if one is 0 the other is 0, and likewise
# if one is 1 the other must also be 1. This property holds over great distances so even after separating
# if either is measure the partner instantly knows the result. This should sound weird because cause and
# effect would normally be though as being limited by the speed of light.
x = Qubit.new(1, 0)
y = Qubit.new(1, 0)
raise unless C_NOT_GATE.*(H_GATE * x, y) == State.new(Matrix[[0.7071067811865475], [0.0], [0.0], [0.7071067811865475]])