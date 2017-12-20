#version 400

#if VERTEX_SHADER
layout(location=0) in vec3 position;
layout(location=1) in vec2 uv;
out vec3 Position;
out vec2 TexCoord;
uniform mat4 PVM;

void main()
{
  Position = position;
  TexCoord = uv;
  gl_Position = PVM * vec4(position, 1.0);
}
#endif

#if FRAGMENT_SHADER
in vec3 Position;
in vec2 TexCoord;
out vec4 FragColor;

uniform vec3 LightDirection;
uniform vec3 LightColor;
uniform vec3 AmbientColor;
uniform vec3 ViewPosition;
uniform vec3 WaterColor = vec3( 0.5, 0.6, 0.95 );
uniform float WaterShininess = 128.0;
uniform mat4 Model;
uniform float Time;

uniform sampler2D NormalMap;

vec3 phong(vec3 targetDir, vec3 normal)
{
  vec3 ambient = AmbientColor * WaterColor;
  float sDotN = max(dot(-LightDirection, normal), 0.0);
  vec3 diffuse = sDotN * LightColor * WaterColor;
  vec3 specular = vec3(0.0);
  if(sDotN > 0.0)
  {
    float specAmp = dot(targetDir, reflect(LightDirection, normal));
    specular = LightColor * WaterColor * pow( max(specAmp, 0.0) , WaterShininess);
  }
  return ambient + diffuse + specular;
}

void main()
{
  vec3 targetDir = normalize((Model*vec4(Position,1.0)).xyz - ViewPosition);
  vec3 normal = normalize(texture(NormalMap, TexCoord + 0.1*vec2(Time)).rgb);
  float dirDotN = dot(targetDir,vec3(0,0,-1)); // 1: look through, 0: opaque
  //FragColor = vec4( normal + 0.01*phong( Position, vec3(0, 0, 1) ), 1.0);
  FragColor = vec4( phong( targetDir, normal ), (1-0.5*dirDotN));
}
#endif