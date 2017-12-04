import std.stdio, std.typecons;
import poodinis;
import gfm.opengl, gfm.sdl2;
import engine;
import doxelgame, inputhandler, player;

void main()
{
	run();
}

void run()
{
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