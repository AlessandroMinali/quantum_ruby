# QuantumRuby

This is a quantum computer simulator in under 300 lines of ruby. Meaning you can build arbitrarily large quantum circuits programmatically and simulate their behaviours.

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Qcircuit_CNOTfromSQRTSWAP.svg/1024px-Qcircuit_CNOTfromSQRTSWAP.svg.png" />

Learning about quantum computing isn't that difficult. Trust me! I learned and built this simulator within a week with no prior quantum computing knowledge. This gem can also be a great tool to facilitate learning about quantum computing.

- [Check out the many examples in this repo.](https://github.com/AlessandroMinali/quantum_ruby/tree/master/examples)  
- [The source code is highly annotated so don't be afraid to check it out.](https://github.com/AlessandroMinali/quantum_ruby/blob/master/lib/quantum_ruby.rb)

## How to learn about Quantum Computers
1. Have an understanding of Linear Algebra. This [series of youtube lectures](https://www.youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab) can get you up to speed on everything you need to know
2. Read this great intro to quantum computing. This is the single resource that I read before I began implementing this simulator: [Quantum computing for the very curious](https://quantum.country/qcvc)
3. Experiment with this simulator as you learn about quantum computing
4. Read the [other articles](https://quantum.country) about quantum computing. Read wiki pages about [qubits](https://en.wikipedia.org/wiki/Qubit) and [quantum gates](https://en.wikipedia.org/wiki/Quantum_logic_gate). Both should be understandable to you now!
5. If you ever get stuck start back at the top of this list or reach out to me with questions: `alessandro.minali AT gmail DOT com`

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'quantum_ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install quantum_ruby
In your code:
```ruby
require 'quantum_ruby`
```

## Usage

**This gem adds `Matrix#kronecker` and `Complex#round` onto ruby base classes**

There are three objects that this gem uses to simulate any quantum circuitry.

---
### Qubit
Quantum computing is achieved by manipulating quantum bits(ie. qubits). For simulation purposes we can arbitrarily create qubits, manipulate them and read their results.

```ruby
qubit_1 = Qubit.new(1, 0)
qubit_1.measure # returns 0 bit
qubit_2 = Qubit.new(0, 1)
qubit_2.measure # returns 1 bit
```

---

### Gate
Quantum gates perform operations on single or multi qubits to produce a variety of classical and non-classical behaviours(such as superpositions and entanglement). Gates are simulated as matrices and interact with qubits via multiplication.

```ruby
# single qubit gate example (X_GATE ie. quantum NOT gate)
qubit_1 = Qubit.new(0, 1) # equivalent to classical 1 bit
state = X_GATE * qubit_1
state.measure # returns 0 bit

# multi qubit gate example (C_NOT_GATE ie. controlled NOT gate)
control_qubit = Qubit.new(1, 0) # 0 bit
target_qubit  = Qubit.new(0, 1) # 1 bit
# note multi params syntax: "GATE.*(param1, param2, etc.)"
state = C_NOT_GATE.*(control_qubit, target_qubit) 
state.measure_partial(target_qubit) # return 1 bit since control is 0

# again with control bit ON
control_qubit = Qubit.new(0, 1) # 1 bit
target_qubit  = Qubit.new(0, 1) # 1 bit
state = C_NOT_GATE.*(control_qubit, target_qubit) 
state.measure_partial(target_qubit) # return 0 bit since control is 1
```

#### Provided Gates
X_GATE  
Y_GATE  
Z_GATE  
H_GATE  
T_GATE  
C_NOT_GATE  
SWAP_GATE  
TOFFOLI_GATE  
Information about any of these gates behaviours can be found [here on wiki](https://en.wikipedia.org/wiki/Quantum_logic_gate).

#### Advanced Gate Usage

#### 1. Making your own gates
This can be done simply like creating a ruby `Matrix`:
```ruby
x = Matrix[[0, 1], [1, 0]]
y = Gate[[0, 1], [1, 0]]
```
Note: A true quantum gate must be [unitary](https://en.wikipedia.org/wiki/Unitary_matrix). You can verify if your creation is unitary with the built-in `Matrix#unitary?`
###### [some versions of ruby have a broken implementation of this function](https://github.com/ruby/matrix/pull/14)
#### 2. `Matrix#kronecker(matrix)`
This method allows you to parallelize and scale gates. Examples follow:

Parallel Gates:
<img src="https://upload.wikimedia.org/wikipedia/commons/d/d5/Parallel_quantum_logic_gates.png" />
```ruby
Y_X_GATE = Y_GATE.kronecker(X_GATE)
```

Scaling Gate:
<img src="https://upload.wikimedia.org/wikipedia/commons/d/d2/Shows_the_application_of_a_hadamard_gate_on_a_state_that_span_two_qubits.png" />
```ruby
state = State.new(Matrix.column_vector([0, 0, 0, 1]))
# H_GATE normally only works on 1 qubit ie. 2x1 matrix
# the following will auto scale H_GATE with kronecker
new_state = H_GATE.*(state, scale: :down)
```

---

### State

Generally once a qubit enters a circuit we no longer care about it. We are instead interested in the combine state of the whole circuit where multiple qubits are being processed by gates. After sending the qubits through a circuit this object will hold their results in a probabilistic model. We can take a measurement to get classical information back out of the qubits.

```ruby
qubit_1 = Qubit.new(0, 1) # equivalent to classical 1 bit
state = H_GATE * qubit_1
state.measure # returns 0 bit or 1 bit with equal probability
```

#### `State#measure` vs `State#measure_partial(qubits)`
In multi-qubit systems gates put the qubits into a combined state. We can either measure the entire state to determine an outcome or try to extract information about specific qubits at the expense of information of the total system. In most cases we are interested in `State#measure`. Make sure you understand which one you intend to do in any situation. [Resource](https://quantum.country/teleportation#background_partial_measurement)

## Other Resources
For some trickier aspects of quantum computing these online resources really helped me grasp deeper concepts:
- https://quantumcomputing.stackexchange.com/questions/9614/how-to-interpret-a-4-qubit-quantum-circuit-as-a-matrix/9615#9615
- https://quantumcomputing.stackexchange.com/questions/4252/how-to-derive-the-cnot-matrix-for-a-3-qbit-system-where-the-control-target-qbi
- https://cs.stackexchange.com/questions/71462/how-are-partial-measurements-performed-on-a-n-qubit-quantum-circuit

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AlessandroMinali/quantum_ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
