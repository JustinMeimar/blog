// Debugger must live in separate global to avoid observing itself.
// Specifically, we put it in a separate "compartment" - an isolated
// memory and garbage collection boundary.
var debuggerGlobal = newGlobal({newCompartment: true});
debuggerGlobal.debuggeeGlobal = this;
// The function we want to set a debugger event in.
function factorial(n) {
    if (n <= 1) {
        // Trigger a trap which gets caught by the debugger.
        debugger;
        return 1;
    }
    return n * factorial(n - 1);
}
// Evaluates our debugger hook, wrapped in an IIFE, in the
// debuggers compartment.
debuggerGlobal.eval("(" + function() {
    var dbg = new Debugger(debuggeeGlobal);
    // Hook to fire on debugger statements
    dbg.onDebuggerStatement = function(frame) {
      for (var f = frame; f; f = f.older) {
        print(f.callee?.name);
      }
    };
} + ")();");
factorial(5);
