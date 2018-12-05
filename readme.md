# Doxel
[![Build Status](https://travis-ci.org/peerhenry/doxel.svg?branch=master)](https://travis-ci.org/peerhenry/doxel/)
[![Coverage Status](https://coveralls.io/repos/github/peerhenry/doxel/badge.svg?branch=master)](https://coveralls.io/github/peerhenry/doxel?branch=master)

A voxel engine in [D](https://dlang.org/).

![demo](https://github.com/peerhenry/doxel/blob/master/Capture.PNG)

## Instructions

Run with `dub run`. Note that as of 05-12-2018, startup takes a long time to generate the initial world.

## Features

- Perlin noise height map generation.
- Skybox.
- Normal map for water waves.
- Distant chunks render voxels as points.

## Planned Features

- First person movement/collision detection.
- Shadow mapping.
- Water reflection.
- Far distance LOD rendering.