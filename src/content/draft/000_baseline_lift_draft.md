
# Lifting Up SpiderMonkey's Baseline Interpreter

This is part one of an development blog on the topic of lifting up SpiderMonkey's baseline-interpreter - the initial JIT tier responsible for 60% speedup [1] over the generic interpreter. What we mean by lifting up requires some historical context.

### Writing an Interpreter

High perforance interpreters have historically been written in assembly [2]. High level languages like C have strugled optimize interpreter patterns. For example, a naive swtich statement loop can not be automatically optimized into a.

TODO: Why exactly is a threaded goto interpreter written in C not qualified as optimized equally as an assembly counterpart?

For SpiderMonkey, the emiting assembly accross several instruction sets (ARM, x86) and operating systems (Windows, OSX, Unix, BSD) creates portability challenge. The macro assembler (MASM) provides an architecture agnostic interface for emiting assembly which the SM developers could then use to write code like interpreters, JIT trampolines, JIT codegen, only once rather than for every architecture [3](v8 used to develop nine JITs in parallel.) 

The MASM was so ergonomic in fact, that it was used to write the baseline interpreter itself. As a result, baseline-interpreter is _generated at runtime_.

[IMG] from Jan De Mooj's blog post.

### Lifting up Baseline

Lifting up baseline means taking the runtime generated baseline interpreter and making it available at compile time, also called ahead-of-time (AOT). The challenge of lifting up baseline is a bootstrapping one.

To talk about the contribution of the baseline interpreter to JIT speedup we must address it's fundamental mechanism for doing so - Inline Caches. TODO: Inline cache description. The bennefit of an AOT baseline interpreter is not just startup time, but primarily that it makes easier the ability to bake in or pre-compile inline cache stubs that can be made available at startup.


### Part One: Where to even start?

The advice given to me was to snapshot the baseline interpreter binary after it is generated at runtime and dump it to a file, say `bl_interp_1.bin`. Do that once more to attain `bl_interp_2.bin` then dissasmble and start analyzing the diffs (with ASLR turned off for simplicity).

```
_basline_prologue:

_basline_opcode_handlers:

# emit_LoadProp
# emit_Add
# emit_Symbol

_baseline_threaded_dispatch_table:

_baseline_epilogue:


```

There were two sources of variation between the generated interpreters. The first was an absolute address being loaded into a register

```
< movabs rbx, 0x7ffff6228480
> movabs rbx, 0x7ffff6228880
```

The second was an array of ~255 adresses. The array was relatively intuive - happening to correspond in size to the number of JS opcodes the basline interpreter emitted - this was clearly the threaded dispatch table. The first source of variation however, was non-obvious. It was occuring somewhere in one of the op-handlers, but which one? That is not so clear.

#### Tracing JIT Code to it's Origin

A JIT compiler generates code at runtime. This means we allocate a buffer (data), use the MacroAssembler to emit instructions into this buffer, then mark that data as read-only and executable once done. To ttrace the origin of the movabs instruction we could set a GDB watchpoint at the MASM handle respondible for emiting an `ImmPtr` at step through it. This could be tedious howver, there may be many more invocations of this instruction than grains of debugging patience.

This is where `rr` comes in, the record and replay debugger. With `rr` one can record execution with snapshots the program state, enabling one to "debug in reverse". This is exactly what we need for our case. We know the offset of the `movabs` instruction in the jitcode, hence we know the runtime address, however, we don't know when it is written to. With `rr` we can set a hardware watchpoint for this address and reverse-continue until it is written. Bearing a few false positives triggered by MASM buffer re-allocations, we can trace it back to this opcode handler:

```c++
bool BaselineInterpreterCodeGen::emit_Symbol() {
  Register scratch1 = R0.scratchReg();
  Register scratch2 = R1.scratchReg();
  LoadUint8Operand(masm, scratch1);

  masm.movePtr(ImmPtr(&runtime->wellKnownSymbols()), scratch2); // Here!
  masm.loadPtr(BaseIndex(scratch2, scratch1, ScalePointer), scratch1);

  masm.tagValue(JSVAL_TYPE_SYMBOL, scratch1, R0);
  frame.push(R0);
  return true;
}

```

> An interesting rr artifact. An x86 instruction like movabs is 10 byytes. Since reverse continue sets a hardware watchpoint on the word level, it gets triggered from the far side when writing the third word. As a result, disassembling this address can be confusing since the watchpoint is triggerd at the remaining two bytes of a 10 byte instruciton.  

As we can see, this opcode bakes in a pointer to the JS runtime.
This is clearly going to change each time we invoke the engine,
so now that we have traced the source, we need some method of 
reloacting this pointer in the AOT setting.


### Automatic Relocation Generation




