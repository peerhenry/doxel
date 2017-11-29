import std.stdio, std.typecons;

import poodinis;
import gfm.opengl;

import engine;

import doxel.doxelgame;

void main()
{
	run();
}

void run()
{
	int width = 1280;
	int height = 720;
	Context context = new Context(width, height, "Doxel");
	scope(exit) context.destroy;

	Camera cam = new Camera();
	cam.setRatio(16.0/9);
	auto container = new shared DependencyContainer();
	container.register!OpenGL.existingInstance(context.gl);
	container.register!Camera.existingInstance(cam);
  container.register!(Game, DoxelGame);
	Game game = container.resolve!Game;
	scope(exit) game.destroy;

	context.run(game);
}