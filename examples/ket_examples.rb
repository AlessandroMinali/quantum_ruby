require_relative '../lib/quantum_ruby'
# 'Ket' visualization
# Supports Bra-ket notation
x = Qubit.new(1, 0)
raise unless x.to_s == '1|0>'

x = Qubit.new(0, 1)
raise unless x.to_s == '1|1>'

# Complex number visualization
x = Qubit.new((1 + 1i) / 2, 1i / Math.sqrt(2))
raise unless x.to_s == '1/2+1/2i|0> + 0.707i|1>'
raise unless x.state == "[1/2+1/2i\n 0.707i]"