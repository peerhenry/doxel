import std.stdio, core.exception, std.format;

static int[string] suiteFails;
string[] suiteStack;
static bool firstSuiteOrTest = true;
static int failCount = 0;
static string indent = "";

void runsuite(string name, void delegate() suite)
{
  if(firstSuiteOrTest)
  {
    writeln("");
    firstSuiteOrTest = false;
  }
  beginSuite(name);
  suite();
  endSuite();
}

void beginSuite(string name)
{
  suiteStack ~= name;
  suiteFails[name] = 0;
  writeln(indent~"Test suite: ", name);
  //writeln("");
  indent ~= "  ";
}

void endSuite()
{
  indent = indent[0..($-2)];
  string suiteName = suiteStack[$-1];
  int suiteFailCount = suiteFails[suiteName];
  suiteFailCount == 0 ? writeln(indent~"Suite report: All test passed.") :  writeln(indent~"Suite report: ", suiteFailCount, " tests failed.");
  writeln("");
  suiteFails[suiteName] = 0;
  suiteStack = suiteStack[ 0..($-1)]; // pop
}

void incrementSuiteFail()
{
  if(suiteStack.length>0)
  {
    string currentSuite = suiteStack[$-1];
    suiteFails[currentSuite] += 1;
  }
}

//static void runtest(string name, void function() @system function() nothrow @nogc @safe test)
void runtest(string name, void delegate() test)
{
  bool pass = true;
  try
  {
    test();
  }
  catch(AssertError error)
  {
    writeln(indent~error.msg);
    incrementSuiteFail();
    pass = false;
  }
  if(!pass) failCount++;
  writeln(indent~(pass ? "PASS: " : "FAIL: "), name);
}

void runTest(string name, void delegate() test)
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
    //writeln("Assertion failed, expected: ", expected, " actual: ", result);
    //throw error;
    string msg = format!("Assertion failed, expected: %s actual: %s")(expected, result);
    throw new AssertError(msg);
  }
}

void fail(string msg)
{
  throw new AssertError(msg);
}

void fail()
{
  throw new AssertError("Fail.");
}