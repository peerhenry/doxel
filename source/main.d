import std.stdio, std.typecons;
import poodinis;
import gfm.opengl, gfm.sdl2;
import engine;
import doxelgame, inputhandler, player;

static bool toRun = true;
unittest{
	toRun=false; 
}

void main()
{
	if(toRun)run();
	else{
		import testrunner;
		writeln("");
		failCount == 0? writeln("Test report: All test passed.") :  writeln("Test report: ", failCount, " tests failed.");
		writeln("");
	}
}

void run()
{
	import core.memory;
	//GC.disable();
	
	int width = 1920;
	int height = 1080;
	Context context = new Context(width, height, "Doxel");
	scope(exit) context.destroy;

	Camera cam = new Camera();
	cam.setRatio(16.0/9);
	Player player = new Player(cam, 2);

	auto container = new shared DependencyContainer();

	// register dependencies
	container.register!OpenGL.existingInstance(context.gl);
	container.register!Context.existingInstance(context);
	container.register!Camera.existingInstance(cam);
	container.register!Player.existingInstance(player);
	container.register!InputHandler;
  container.register!(Game, DoxelGame);

	Game game = container.resolve!Game;
	scope(exit) game.destroy;
	context.run(game);
}