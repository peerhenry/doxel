import std.stdio, core.exception;

static int failCount = 0;

//static void runtest(string name, void function() @system function() nothrow @nogc @safe test)
void runtest(string name, bool delegate() test)
{
  bool pass = true;
  try
  {
    pass = test();
  }
  catch(AssertError error)
  {
    writeln(error.msg);
    writeln(error.info);
    pass = false;
  }
  if(!pass) failCount++;
  writeln(pass ? "PASS: " : "FAIL: ", name);
}

void runTest(string name, bool delegate() test)
{
  runtest(name, test);
}

void assertEqual(T)(T expected, T result)
{
  try
  {
    assert(expected is result);
  }
  catch(AssertError error)
  {
    writeln("Assertion failed, expected: ", expected, " actual: ", result);
    throw error;
  }
}