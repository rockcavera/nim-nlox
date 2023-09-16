# Benchmark
The benchmark brings the best of 3 measurements for the base jlox implementation and the nlox implementation. The measurements were made on an `Intel(R) Core(TM) i7-4810MQ` with the frequency locked at 2.80GHz, to avoid Turbo Boost

nlox was compiled as: `nim c --threads:off -d:danger --mm:arc --panics:on -d:lto -d:nloxBenchmark nlox`

jlox was compiled as: `javac *.java`

## binary_trees.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 18.36000000000058  | 1.79x  |
| jlox  | 10.240000009536743  | 1.00x  |

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
18.36000000000058
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
10.240000009536743
```

## equality.lox

### elapsed
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 12.64699999999721  | 2.54x  |
| jlox  | 4.980999946594238  | 1.00x  |

### loop
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 9.900999999998021  | 2.58x  |
| jlox  | 3.8410000801086426  | 1.00x  |

### equals
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 2.745999999999185  | 2.41x  |
| jlox  | 1.1399998664855957  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
loop
9.900999999998021
elapsed
12.64699999999721
equals
2.745999999999185
```
jlox
```
loop
3.8410000801086426
elapsed
4.980999946594238
equals
1.1399998664855957
```

## fib.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 17.78499999999622  | 3.00x  |
| jlox  | 5.924000024795532  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
true
17.78499999999622
```
jlox
```
true
5.924000024795532
```

## instantiation.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 7.419999999998254  | 3.46x  |
| jlox  | 2.1419999599456787  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
7.419999999998254
```
jlox
```
2.1419999599456787
```

## invocation.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 7.756000000001222  | 4.11x  |
| jlox  | 1.8849999904632568  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
7.756000000001222
```
jlox
```
1.8849999904632568
```

## method_call.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 3.694999999999709  | 1.40x  |
| jlox  | 2.636000156402588  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
true
false
3.694999999999709
```
jlox
```
true
false
2.636000156402588
```

## properties.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 11.94900000000052  | 1.72x  |
| jlox  | 6.9659998416900635  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
11.94900000000052
```
jlox
```
6.9659998416900635
```

## string_equality.lox

### elapsed
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 10.79399999999441  | 1.88x  |
| jlox  | 5.740000009536743  | 1.00x  |

### loop
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 9.272000000004482  | 2.16x  |
| jlox  | 4.302000045776367  | 1.00x  |

### equals
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 1.52199999998993  | 1.00x  |
| jlox  | 1.523000000008324  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
loop
9.272000000004482
elapsed
10.79399999999441
equals
1.52199999998993
```
jlox
```
loop
4.302000045776367
elapsed
5.740000009536743
equals
1.437999963760376
```

## trees.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 39.22799999999552  | 1.07x  |
| jlox  | 36.52900004386902  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
39.22799999999552
```
jlox
```
36.52900004386902
```

## zoo.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 8.877999999996973  | 1.28x  |
| jlox  | 6.908999919891357  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
10000002
8.877999999996973
```
jlox
```
1.0000002E7
6.908999919891357
```

## zoo_batch.lox
|   | sum  | batch  | Factor  |
| ------------ | ------------ | ------------ | ------------ |
| nlox  | 11700000  | 195 | 0.59x  |
| jlox  | 19800000  | 330 | 1.00x  |

**&#42; bigger "sum" and "batch" is better**

**Outputs:**

nlox
```
11700000
195
10.01599999999598
```
jlox
```
1.98E7
330
10.009999990463257
```

## Notes
`nim -v`
```
Nim Compiler Version 2.1.1 [Windows: amd64]
Compiled at 2023-09-14
Copyright (c) 2006-2023 by Andreas Rumpf

git hash: 38b58239e882eaa905bafa49237f0b9ca9d43569
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