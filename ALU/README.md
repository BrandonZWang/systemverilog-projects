# ALU

The `alu` module implements a variable width arithmetic logic unit.

## Module

`alu` is capable of 16 different operations (see opcode table below) and is paramaterized with a field `WIDTH` that specifies the bit length of the input operands and result. It is purely combinational.

`alu` takes an opcode, two operands, and a carry-in bit as inputs, and outputs a result, carry-out bit, and four flags - `zero`, `negative`, `overflow`, and `parity`.

Note: This ALU implementation does not use the carry-in bit as an extension to the input operand for shift operations, as some ALU implementations do.

## Testbench

`tb_alu` uses a UVM-esque model to randomly and comprehensively test the `alu` module. Since `alu` is purely combinational, the only UVM-like element is the implementation of an `alu_transaction` class that stores inputs and outputs to interact with the DUT.

`tb_alu` accepts several command-line arguments to customize simulation, which should be added when calling `vsim`. <br>
`+verbose` enables verbose logging, which will print additional testbench information, which can be useful for debugging. By default, the testbench logs incorrect results and the final number of correct results. Default: `false` <br>
`+wait_time=ns` specifies the number of nanoseconds to wait in between transactions. Default: `5` <br>
`+num_transactions=n` specifies the number of transactions to execute on the DUT. Each transaction uses completely randomized inputs. Default: `20` <br>

`tb_alu` uses `$urandom` instead of randomize() to create random DUT stimuli. To change the random seed, use `-sv_seed random` when calling `vsim`.

## Table of Opcodes

| Opcode    | Operation              | Result             | Carry out |
| :-:       | :--                    | :--                | :--       |
| `4'b0000` | Passthrough            | `Y = A`            | 0         |
| `4'b0001` | Add                    | `Y = A + B`        | Carry     |
| `4'b0010` | Add with Carry-in      | `Y = A + B + Cin`  | Carry     |
| `4'b0011` | Subtract               | `Y = A - B`        | Carry     |
| `4'b0100` | Subtract with Carry    | `Y = A - B - !Cin` | Carry     |
| `4'b0101` | Two's Complement       | `Y = -A`           | Carry     |
| `4'b0110` | Increment              | `Y = A + 1`        | Carry     |
| `4'b0111` | Decrement              | `Y = A - 1`        | Carry     |
| `4'b1000` | Bitwise AND            | `Y = A AND B`      | 0         |
| `4'b1001` | Bitwise OR             | `Y = A OR B`       | 0         |
| `4'b1010` | Bitwise XOR            | `Y = A XOR B`      | 0         |
| `4'b1011` | Bitwise NOT            | `Y = NOT A`        | 0         |
| `4'b1100` | Arithmetic Shift Right | `Y = A >>> 1`      | LSB of A  |
| `4'b1101` | Logical Shift Right    | `Y = A >> 1`       | LSB of A  |
| `4'b1110` | Shift Left             | `Y = A << 1`       | MSB of A  |
| `4'b1111` | Rotate Left            | `Y = A LRL 1`      | 0         |

## Screenshots



## Resources

[Wikipedia - Arithmetic Logic Unit](https://en.wikipedia.org/wiki/Arithmetic_logic_unit) for example list of opcodes.

[Wikipedia - Carry Flag \ Vs. Borrow Flag](https://en.wikipedia.org/wiki/Carry_flag#Vs._borrow_flag) for difference between subtract with *borrow* and subtract with *carry*.

[SystemVerilog Reduction Operators](https://nandland.com/reduction-operators/) for calculation of parity bit.