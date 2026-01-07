# FPU

The `fpu` module implements the floating point standard as specified in IEEE 754-2019.

## Module

`fpu` uses a double precision format with radix 2 (binary64) under homogenous operation, meaning its inputs and outputs should all be 64-bit binary floating-point numbers.

## Testbench



## Table of Opcodes



## Screenshots



## Intro to Floating Point Numbers
*(a.k.a. my notes on IEE 754-2019)*

Binary floating-point numbers are laid out as such: (§3.4)

<pre>
MSB                       LSB
| S |   E   |       T       |
</pre>

- S = Sign bit. 0 means the number is positive, 1 means the number is negative. S is always 1 bit wide.
- E = Exponent. A implementation-defined bias is subtracted from E to reach the final exponent (e = E - bias).
- T = Trailing significand. The significand is the "base" number which is shifted by the exponent to reach the final number. The MSB of the signifcand is excluded because it is implicit: 1 for normal numbers (because 1 <= T < 2), and 0 for subnormal numbers where 0 < T < 1. (§3.4 see c and d under representation)

Under normal circumstances, the value represented by a binary floating-point number is `(-1)^S * 2^(E - bias) * (1 + 2^(1-p) * T)`. `(-1)^S` determines the sign of the number. `2^(E - bias)` shifts the number left by the biased exponent. `(1 + 2^(1-p) * T)` is the significand as if it had a decimal place after the MSB. (§3.4 c under representation) See Special Numbers for reserved numbers.

Each format comes with three parameters that define the set of representable numbers: (§3.3)
- b = radix, 2 or 10 (2 for binary floats)
- p = precision, the number of bits in the significand. T is (p - 1) bits wide because the MSB is implicit (see above)
- emax = maximum exponent e. emax != maximum value of E (remember, e = E - bias).

### Special Numbers
- If E = 1111... and T != 0, then the number is NaN. If MSB of T is 1, it is a qNaN, if it a 0 then it is an sNaN (see Relevant Definitions). Note sNaN must have some other non-zero bit of T to distinguish from infinity. (§6.2.1)
- 

### Relevant Notes


### Relevant Definitions (§2.1)
- Binary floating-point number - underlying representation is binary (radix 2), not decimal (radix 10)
- Format - A specification for the way binary numbers are represented, including radix, precision, and maximum exponent.
- Subnormal number - Special defined numbers between 0 and the minimum representable "normal" number
- Exception - Raised under certain conditions. See [Wikipedia - IEEE 754 \ Exception Handling](https://en.wikipedia.org/wiki/IEEE_754#Exception_handling)
- Homogenous operation - Implementation takes inputs and gives outputs all in the same format.
- NaN - Not a number. The two types of NaNs: qNaN (quiet NaN) does not signal an exception, while sNaN (signaling NaN) does signal an exception and carries information (see payload)
- Payload - Diagnostic information contained in the significand of an sNaN.
- Biased exponent - Where the exponent is the sum of the exponent field E and a bias (E - bias) to represent negative exponents, rather than two's complement representation.

## Resources

[Wikipedia - IEEE 754](https://en.wikipedia.org/wiki/IEEE_754).

[IEEE 754-2019](https://www-users.cse.umn.edu/~vinals/tspot_files/phys4041/2020/IEEE%20Standard%20754-2019.pdf).