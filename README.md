<p align="center">
  <img width="860" height="559" src="https://raw.githubusercontent.com/sandrolovnicki/pLam/master/res/demo.gif">
</p>

This programming language (pLam - a **p**ure **Lam**bda calculus interpreter) is used to explore, test and implement various λ-expressions. Code written in pLam can be executed interactively within pLam's shell or stored in a file with .plam extension and run anytime.

Inside `import/` directory, some useful λ-expressions are already implemented.  
Inside `examples/` directory, there are many examples of λ-expressions demonstrating pLam's capabilities.

_**Coming soon:** Wiki pages on λ-calculus and computability; detailed description of pLam's syntax and semantics, existent libraries and capabilities with examples_

---

## Prerequisites
This project builds using Haskell tool stack documented at https://docs.haskellstack.org/en/stable/README/.

On most Unix systems, you can get stack by typing:
```
curl -sSL https://get.haskellstack.org/ | sh
```
or:
```
wget -qO- https://get.haskellstack.org/ | sh
```
On Windows, you can download 64-bit installer given at https://docs.haskellstack.org/en/stable/README/.

## Build & Run
### First time setup
1. clone project repository
```
git clone https://github.com/sandrolovnicki/pLam.git
```
2. go to project directory
```
cd pLam
```
3. setup stack on isolated location
```
stack setup
```
### Building
4. use stack to build project
```
stack build
```
### Running (locally)
5.a) use stack to run project executable from project's directory
```
stack exec plam
```
### Running (globally (Unix systems))
5.b) use `make_global.sh` script to create a global command 'plam' that can be used to start pLam from anywhere in your system. The script will also change your import path in src/Config.hs so you need to build the project again.
```
sudo ./make_global.sh
stack build
```
Now, (and anytime in the future!), you can start pLam from anywhere in your system by just typing
```
plam
```

## Examples

**NOTE:** Output might be slightly different due to constant fixes and changes. Fully updated examples will be put each time they diverge too far from current.  
All the examples can be found in `examples/` directory.

### Fun with booleans
```
         _
        | |
    ____| |   ___  __  __
    | _ \ |__| _ \|  \/  |
    |  _/____|____\_\__/_| v1.3.1
    |_| pure λ-calculus interpreter
   =================================

pLam> :import booleans
pLam> 
pLam> and (or F (not F)) (xor T F)
> reductions count              : 18
> uncurried β-normal form       : (λxy. x)
> curried (partial) α-equivalent: T
pLam>
```

#### Redex coloring
![redex_coloring.png](https://raw.githubusercontent.com/sandrolovnicki/pLam/master/res/redex_coloring.png "Redex Coloring")

### Fun with arithmetic
```
pLam> :import std
pLam> 
pLam> mul (add 2 (Sc 2)) (sub (exp 2 3) (Pc 8))
> reductions count              : 762
> uncurried β-normal form       : (λfx. f (f (f (f (f x)))))
> curried (partial) α-equivalent: 5
pLam> 
```

### Factorial
```
pLam> :import std
pLam> :import comp
pLam>
pLam> fact = PR0 1 (C22 mul (C2 S I12) I22)
pLam> fact 3
> reductions count              : 898
> uncurried β-normal form       : (λfx. f (f (f (f (f (f x))))))
> curried (partial) α-equivalent: 6
pLam> 
```

### Minimization
#### interactive coding:
```
pLam> :import std
pLam> :import comp
pLam> 
pLam> fun = \x. mul (sub 2 x) (sub 3 x)
pLam> MIN1 fun
> reductions count              : 114
> uncurried β-normal form       : (λfx. f (f x))
> curried (partial) α-equivalent: 2
pLam> 
```
#### running the existing program:
```
pLam> :run examples/2.5.2
=================================
< zero
=================================
> reductions count              : 114
> uncurried β-normal form       : (λfx. f (f x))
> curried (partial) α-equivalent: 2
pLam>
```
#### running the existing program (without entering pLam's shell):
```
plam ~/Projects/pLam/examples/2.5.2.plam
=================================
< zero
=================================
> reductions count              : 114
> uncurried β-normal form       : (λfx. f (f x))
> curried (partial) α-equivalent: 2
Done.
```

### Binary numerals
```
         _
        | |
    ____| |   ___  __  __
    | _ \ |__| _ \|  \/  |
    |  _/____|____\_\__/_| v1.3.1
    |_| pure λ-calculus interpreter
   =================================

pLam> :import binary
pLam>
pLam> 0b
> reductions count              : 2
> uncurried β-normal form       : (λp.((p (λxy. y)) (λexy.x)))
> curried (partial) α-equivalent: 0b
pLam> 
pLam> 2048b
> reductions count              : 24
> uncurried β-normal form       : (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. y)) (λp.((p (λxy. x)) (λexy.x)))))))))))))))))))))))))
> curried (partial) α-equivalent: (λp. ((p F) 1024b))
pLam>
pLam>
pLam> addB 7b (subBs 2b 3b)
> reductions count              : 9458
> uncurried β-normal form       : (λp.((p (λxy. x)) (λp.((p (λxy. x)) (λp.((p (λxy. x)) (λexy.x)))))))
> curried (partial) α-equivalent: 7b
pLam>
pLam> :quit
Goodbye!
```

---

**Disclaimer for Haskell experts**  
I am not a Haskell expert. In fact, this is my first and only Haskell project. It is inevitable that existing code could be written better and I wish to do it in the upcoming future.  
The goal of the project was to create an environment for easy building of new expressions from previously defined ones, so that one could explore λ-calculus. It was a helper tool so I could define and test a new numeral system in λ-calculus, for my master thesis. Now, when this all went well, the time is coming for me to get back to Haskell code.
