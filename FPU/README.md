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
- E = Exponent. A implementation-defined bias is subtracted from E to reach the final exponent (e = E - bias). Values 0 and 2^w - 1 are reserved for special numbers.
- T = Trailing significand. The significand is the "base" number which is shifted by the exponent to reach the final number. The MSB of the signifcand is excluded because it is implicit: 1 for normal numbers (because 1 <= T < 2), and 0 for subnormal numbers where 0 < T < 1. (§3.4 see c and d under representation)

Under normal circumstances, the value represented by a binary floating-point number is `(-1)^S * 2^(E - bias) * (1 + 2^(1-p) * T)`. `(-1)^S` determines the sign of the number. `2^(E - bias)` shifts the number left by the biased exponent. `(1 + 2^(1-p) * T)` is the significand as if it had a decimal place after the MSB. (§3.4 c under representation) See Special Numbers for reserved numbers.

### Parameters (§3.3)
Each format comes with three parameters that define the set of representable numbers:
- b = radix, 2 or 10 (2 for binary floats)
- p = precision, the number of bits in the significand. T is (p - 1) bits wide because the MSB is implicit (see above)
- emax = maximum actual value of the exponent e. emax != maximum value of E (remember, e = E - bias).

Additionally, the following parameters are useful for thinking about floating-point numbers:
- w = bit width of the exponent field E. emax = 2^w - 1.
- t = bit width of the trailing significand field T. t = p - 1.
- bias = bias value of the exponent. bias = emax to split the range of E evenly.
- e = actual value of the exponent in the number. e = E - bias.
- emin = minimum actual value of the exponent e. emin = -emax + 1.

This FPU implements binary64 (double precision), which has `b = 2`, `p = 53`, `emax = bias = 1023`, `w = 11`, `t = 52`, and `emin = -1022`. (§Table 3.5)

### Special Numbers (§3.4)
The values of E = 0 and 2^w - 1 (1111...) are reserved for special representations of numbers:
- If E = 1111... and T != 0, then the number is NaN. If MSB of T is 1, it is a qNaN, if it a 0 then it is an sNaN (see Relevant Definitions). Note sNaN must have some other non-zero bit of T to distinguish from infinity. (§6.2.1)
- If E = 1111... and T = 0, then the number is ±∞, depending on the sign bit S.
- If E = 0 and T != 0, then the number is subnormal and is caluclated as `(-1)^S * 2^(emin) * (0 + 2^(1-p) * T)`. Note `emin` instead of `E - bias`, and `0 + ...` instead of `1 + ...`
- If E = 0 and T = 0, then the number is ±0, depending on the sign bit S.

| | T = 0 | T != 0 |
|-|-|-|
| **E = 0** | ±0 | subnormal
| **E = 1111...** | ±∞ | qNaN / sNaN

### Attributes (§4)
User-set and specify how certain behaviors should be handled.
- roundTies (§4.3.1) - determines which direction numbers should be rounded if they are equally far from both nearest representable numbers. If roundTiesToAway is set, then round to the larger magnitude number. If roundTiesToEven is set, then round to the nearest even signifcand, or the larger magnitude if that isn't possible. Binary representations must have roundTiesToEven by default. (§4.3.3)
- roundTowards (§4.3.2) - determines which way all numbers should be rounded. Attributes are roundTowardPositive, roundTowardNegative, and roundTowardZero.

Other non-relevant attributes:
- Alternative excpetion handling (§8) - Not relevant as `fpu` will only raise flags, not handle exceptions.
- preferredWidth (§10.3) - not relevant under homogenous operation.
- Literal meaning (§10.4) - deals with source code translation, not individual operations.
- Reproducibility (§11) - Not relevant as it concerns the translation of code into operations. `fpu` will be completely deterministic.

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