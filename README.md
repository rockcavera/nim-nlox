nlox is a Nim implementation of the Lox programming language interpreter. This implementation is based on the jlox interpreter, which is done in Java.

## What is Lox?
Lox is a scripting language created by Robert Nystrom to teach in a practical way the implementation of a programming language throughout the book Crafting Interpreters. To learn more, visit [craftinginterpreters.com](https://www.craftinginterpreters.com/).

## Why write another Lox interpreter?
I have always been interested in learning how a programming language is implemented and the book Crafting Interpreters brings this in a very didactic and practical way. So it's a perfect opportunity to learn something new and develop myself as a programmer.

## Why use the Nim programming language?
Nim is currently the programming language I have the best aptitude for and I feel more comfortable exploring something new and unknown. I tried to keep this Nim implementation as faithful as possible with the base implementation made in Java.

### Challenges when using Nim
Certainly the biggest challenge during codification was avoiding cyclical imports that are prohibited in Nim, which emerged as chapter by chapter progressed. To achieve this, some refactorings were necessary, which meant that some codes were left out of comparable files in the Java implementation, such as types, which I had to include for the most part in `src/nlox/types.nim`, which is a very popular practice in Nim.

The second biggest problem was trying to emulate the Java `equals()` method, which underwent some changes throughout the chapters and I still believe there is something missing...

Another part that underwent a lot of refactoring were the literals, such as Number, String, Boolean and Nil. At first I adopted variants objects of Nim , but with the arrival of expression evaluations, this approach proved to be a mistake, making it necessary to switch to objects with inheritance. It was a painful but necessary refactoring.

Finally, from the beginning I knew that I would need to pass a state from the interpreter, but I didn't want to do that with globals. To this end, I first adopted global ones, so that when the interpreter had become more consolidated, I created a `Lox` object to store the state of the interpreter and pass it wherever necessary.

## Progress
I. WELCOME
- [x] 1. Introduction
- [x] 2. A Map of the Territory
- [x] 3. The Lox Language

II. A TREE-WALK INTERPRETER
- [x] 4. Scanning
- [x] 5. Representing Code
- [x] 6. Parsing Expressions
- [x] 7. Evaluating Expressions
- [x] 8. Statements and State
- [x] 9. Control Flow
- [x] 10. Functions
- [x] 11. Resolving and Binding
- [x] 12. Classes
- [x] 13. Inheritance

As you can see, nlox is a complete Lox interpreter based on the Java version.

## How to use nlox?
First you need to have a [Nim](https://nim-lang.org/install.html "Nim") 2.0.0 compiler or higher.

Then clone this repository:
```
git clone https://github.com/rockcavera/nim-nlox.git
```

Enter the cloned folder:
```
cd nim-nlox
```

Finally, compile the project:
```
nim c -d:release src/nlox
```

or install with Nimble:
```
nimble install
```

For best performance, I recommend compiling with:
```
nim c -d:danger -d:lto --mm:arc --panics:on src/nlox
```

## How to perform tests?
Assuming you have already cloned the repository, just be in the project folder and type:
```
nim r tests/tall
```

or:
```
nimble test
```

## nlox vs jlox benchmark
visit [BENCHMARK.md](BENCHMARK.md)


## License
All files are under the MIT license, with the exception of the .lox files located in the tests/scripts folder, which are under this [LICENSE](/tests/scripts/LICENSE) because they are third-party code, which can be accessed [here](https://github.com/munificent/craftinginterpreters/tree/master/test).
