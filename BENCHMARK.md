# Benchmark
The benchmark brings the best of 3 measurements for the base jlox implementation and the nlox implementation. The measurements were made on an `Intel(R) Core(TM) i7-4810MQ` with the frequency locked at 2.80GHz, to avoid Turbo Boost

nlox was compiled as: `nim c --threads:off -d:danger --mm:arc --panics:on -d:lto --passC:-march=native nlox`

jlox was compiled as: `javac *.java`

**Comments**

1.  The nlox implementation, i.e. in Nim, now precomputes the hashes of the `Expr` and `String` objects, which are used in hash tables. This optimization was made after verifying, through Intel VTune, that the `murmurHash()` procedure took more execution time. This raised the question of how to improve the hashing algorithm. But, after thinking a lot, the best solution was to use cache, considering that it would already be possible to know them during the static analysis (resolve). In order not to cheat with the Java implementation, it was also researched that the JVM calculates the hash of an object only once and stores it in cache to later reuse if the object is not modified, making querying hash tables a constant operation. In other words, this hash precomputation in JVM also occurs during the static analysis phase, before dynamic execution (evaluation).

## binary_trees.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 11.55900001525879  | 1.13x  |
| jlox  | 10.2279999256134  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
stretch tree of depth:
15
check:
-1
num trees:
32768
depth:
4
check:
-32768
num trees:
8192
depth:
6
check:
-8192
num trees:
2048
depth:
8
check:
-2048
num trees:
512
depth:
10
check:
-512
num trees:
128
depth:
12
check:
-128
num trees:
32
depth:
14
check:
-32
long lived tree of depth:
14
check:
-1
elapsed:
11.55900001525879
```
jlox
```
stretch tree of depth:
15
check:
-1
num trees:
32768
depth:
4
check:
-32768
num trees:
8192
depth:
6
check:
-8192
num trees:
2048
depth:
8
check:
-2048
num trees:
512
depth:
10
check:
-512
num trees:
128
depth:
12
check:
-128
num trees:
32
depth:
14
check:
-32
long lived tree of depth:
14
check:
-1
elapsed:
10.2279999256134
```

## equality.lox

### elapsed
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 9.858999967575073  | 1.95x  |
| jlox  | 5.064000129699707  | 1.00x  |

### loop
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 6.76200008392334  | 1.75x  |
| jlox  | 3.870999813079834  | 1.00x  |

### equals
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 3.096999883651733  | 2.60x  |
| jlox  | 1.193000316619873  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
loop
6.76200008392334
elapsed
9.858999967575073
equals
3.096999883651733
```
jlox
```
loop
3.870999813079834
elapsed
5.064000129699707
equals
1.193000316619873
```

## fib.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 12.1399998664856  | 2.03x  |
| jlox  | 5.976000070571899  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
true
12.1399998664856
```
jlox
```
true
5.976000070571899
```

## instantiation.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 5.596999883651733  | 2.58x  |
| jlox  | 2.167999982833862  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
5.596999883651733
```
jlox
```
2.167999982833862
```

## invocation.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 6.06000018119812  | 3.22x  |
| jlox  | 1.88100004196167  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
6.06000018119812
```
jlox
```
1.88100004196167
```

## method_call.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 2.671000003814697  | 0.99x  |
| jlox  | 2.703000068664551  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
true
false
2.671000003814697
```
jlox
```
true
false
2.703000068664551
```

## properties.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 9.588000059127808  | 1.42x  |
| jlox  | 6.745000123977661  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
9.588000059127808
```
jlox
```
6.745000123977661
```

## string_equality.lox

### elapsed
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 6.279000043869019  | 1.09x  |
| jlox  | 5.746999979019165  | 1.00x  |

### loop
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 4.26200008392334  | 1.01x  |
| jlox  | 4.23199987411499  | 1.00x  |

### equals
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 2.016999959945679  | 1.33x  |
| jlox  | 1.515000104904175  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
loop
4.26200008392334
elapsed
6.279000043869019
equals
2.016999959945679
```
jlox
```
loop
4.23199987411499
elapsed
5.746999979019165
equals
1.515000104904175
```

## trees.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 30.66300010681152  | 0.82x  |
| jlox  | 37.21399998664856  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
30.66300010681152
```
jlox
```
37.21399998664856
```

## zoo.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 5.635999917984009  | 0.81x  |
| jlox  | 6.937000036239624  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
10000002
5.635999917984009
```
jlox
```
1.0000002E7
6.937000036239624
```

## zoo_batch.lox
|   | sum  | batch  | Factor  |
| ------------ | ------------ | ------------ | ------------ |
| nlox  | 18240000  | 304 | 0.94x  |
| jlox  | 19320000  | 322 | 1.00x  |

**&#42; bigger "sum" and "batch" is better**

**Outputs:**

nlox
```
18240000
304
10.0239999294281
```
jlox
```
19320000
322
10.02699995040894
```

## Notes
`nim -v`
```
Nim Compiler Version 2.1.1 [Windows: amd64]
Compiled at 2023-09-19
Copyright (c) 2006-2023 by Andreas Rumpf

git hash: 5568ba0d9f39469891b5e4625ad39ebcfa5e1ee3
active boot switches: -d:release
```

`gcc -v`
```
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=E:/compilers/mingw64/bin/../libexec/gcc/x86_64-w64-mingw32/13.2.0/lto-wrapper.exe
Target: x86_64-w64-mingw32
Configured with: ../../../src/gcc-13.2.0/configure --host=x86_64-w64-mingw32 --build=x86_64-w64-mingw32 --target=x86_64-w64-mingw32 --prefix=/mingw64 --with-sysroot=/c/buildroot/x86_64-1320-posix-seh-msvcrt-rt_v11-rev0/mingw64 --enable-host-shared --disable-multilib --enable-languages=c,c++,fortran,lto --enable-libstdcxx-time=yes --enable-threads=posix --enable-libgomp --enable-libatomic --enable-lto --enable-graphite --enable-checking=release --enable-fully-dynamic-string --enable-version-specific-runtime-libs --enable-libstdcxx-filesystem-ts=yes --disable-libssp --disable-libstdcxx-pch --disable-libstdcxx-debug --enable-bootstrap --disable-rpath --disable-win32-registry --disable-nls --disable-werror --disable-symvers --with-gnu-as --with-gnu-ld --with-arch=nocona --with-tune=core2 --with-libiconv --with-system-zlib --with-gmp=/c/buildroot/prerequisites/x86_64-w64-mingw32-static --with-mpfr=/c/buildroot/prerequisites/x86_64-w64-mingw32-static --with-mpc=/c/buildroot/prerequisites/x86_64-w64-mingw32-static --with-isl=/c/buildroot/prerequisites/x86_64-w64-mingw32-static --with-pkgversion='x86_64-posix-seh-rev0, Built by MinGW-Builds project' --with-bugurl=https://github.com/niXman/mingw-builds CFLAGS='-O2 -pipe -fno-ident -I/c/buildroot/x86_64-1320-posix-seh-msvcrt-rt_v11-rev0/mingw64/opt/include -I/c/buildroot/prerequisites/x86_64-zlib-static/include -I/c/buildroot/prerequisites/x86_64-w64-mingw32-static/include' CXXFLAGS='-O2 -pipe -fno-ident -I/c/buildroot/x86_64-1320-posix-seh-msvcrt-rt_v11-rev0/mingw64/opt/include -I/c/buildroot/prerequisites/x86_64-zlib-static/include -I/c/buildroot/prerequisites/x86_64-w64-mingw32-static/include' CPPFLAGS=' -I/c/buildroot/x86_64-1320-posix-seh-msvcrt-rt_v11-rev0/mingw64/opt/include -I/c/buildroot/prerequisites/x86_64-zlib-static/include -I/c/buildroot/prerequisites/x86_64-w64-mingw32-static/include' LDFLAGS='-pipe -fno-ident -L/c/buildroot/x86_64-1320-posix-seh-msvcrt-rt_v11-rev0/mingw64/opt/lib -L/c/buildroot/prerequisites/x86_64-zlib-static/lib -L/c/buildroot/prerequisites/x86_64-w64-mingw32-static/lib ' LD_FOR_TARGET=/c/buildroot/x86_64-1320-posix-seh-msvcrt-rt_v11-rev0/mingw64/bin/ld.exe --with-boot-ldflags=' -Wl,--disable-dynamicbase -static-libstdc++ -static-libgcc'
Thread model: posix
Supported LTO compression algorithms: zlib
gcc version 13.2.0 (x86_64-posix-seh-rev0, Built by MinGW-Builds project)
```

`java -version`
```
java version "17.0.6" 2023-01-17 LTS
Java(TM) SE Runtime Environment (build 17.0.6+9-LTS-190)
Java HotSpot(TM) 64-Bit Server VM (build 17.0.6+9-LTS-190, mixed mode, sharing)
```