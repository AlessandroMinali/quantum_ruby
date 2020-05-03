require_relative '../lib/quantum_ruby'
# Kronecker product test
# More details here:
#   https://en.wikipedia.org/wiki/Kronecker_product
x = Matrix[[1, 2], [3, 4]]
y = Matrix[[0, 5], [6, 7]]
raise unless x.kronecker(y) == Matrix[[0, 5, 0, 10], [6, 7, 12, 14], [0, 15, 0, 20], [18, 21, 24, 28]]

x = Matrix[[1], [2]]
y = Matrix[[3], [4]]
raise unless x.kronecker(y) == Matrix[[3], [4], [6], [8]]