# Benchmark
The benchmark brings the best of 3 measurements for the base jlox implementation and the nlox implementation. The measurements were made on an `Intel(R) Core(TM) i7-4810MQ` with the frequency locked at 2.80GHz, to avoid Turbo Boost

nlox was compiled as: `nim c --threads:off -d:danger --mm:arc --panics:on -d:lto -d:nloxBenchmark nlox`

jlox was compiled as: `javac *.java`

## binary_trees.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 18.38899999999558  | 1.80x  |
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
18.38899999999558
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
| nlox  | 12.52799999999843  | 2.52x  |
| jlox  | 4.980999946594238  | 1.00x  |

### loop
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 9.974000000001979  | 2.60x  |
| jlox  | 3.8410000801086426  | 1.00x  |

### equals
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 2.553999999996449  | 2.24x  |
| jlox  | 1.1399998664855957  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
loop
9.974000000001979
elapsed
12.52799999999843
equals
2.553999999996449
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
| nlox  | 17.67500000000291  | 2.98x  |
| jlox  | 5.924000024795532  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
true
17.67500000000291
```
jlox
```
true
5.924000024795532
```

## instantiation.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 7.440000000002328  | 3.47x  |
| jlox  | 2.1419999599456787  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
7.440000000002328
```
jlox
```
2.1419999599456787
```

## invocation.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 7.804000000003725  | 4.14x  |
| jlox  | 1.8849999904632568  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
7.804000000003725
```
jlox
```
1.8849999904632568
```

## method_call.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 3.673000000002503  | 1.39x  |
| jlox  | 2.636000156402588  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
true
false
3.673000000002503
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
| nlox  | 11.86699999999837  | 1.70x  |
| jlox  | 6.9659998416900635  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
11.86699999999837
```
jlox
```
6.9659998416900635
```

## string_equality.lox

### elapsed
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 10.7699999999968  | 1.88x  |
| jlox  | 5.740000009536743  | 1.00x  |

### loop
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 9.332000000002154  | 2.17x  |
| jlox  | 4.302000045776367  | 1.00x  |

### equals
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 1.437999999994645  | 0.94x  |
| jlox  | 1.523000000008324  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
loop
9.332000000002154
elapsed
10.7699999999968
equals
1.437999999994645
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
| nlox  | 39.4429999999993  | 1.08x  |
| jlox  | 36.52900004386902  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
39.4429999999993
```
jlox
```
36.52900004386902
```

## zoo.lox
|   | Measurement (s)  | Factor  |
| ------------ | ------------ | ------------ |
| nlox  | 8.88799999999901  | 1.29x  |
| jlox  | 6.908999919891357  | 1.00x  |

**&#42; smaller measurement is better**

**Outputs:**

nlox
```
10000002
8.88799999999901
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
10.02599999999802
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