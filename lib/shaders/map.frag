#version 110

#include <noise3D>

const float WALL_SPACING = 0.01;
const float WATER_SPACING = 0.003;

uniform sampler2D in_Texture; // Original texture.
uniform vec4 in_CavernFloor;
uniform vec4 in_CavernWall;
//uniform vec4 in_Lava;
uniform int in_Seed;

uniform int in_Margin; // In pixels.
uniform vec2 in_TextureSize;

varying vec2 var_TexCoord; // Pixel to process on this pass

void main()
{
    float x = var_TexCoord.x;
    float y = var_TexCoord.y;
    float margin_x = (1.0 / in_TextureSize.x) * float(in_Margin);
    float margin_y = (1.0 / in_TextureSize.y) * float(in_Margin);

    float distance_to_margin_x = min(x - margin_x, (1.0 - margin_x) - x);
    float distance_to_margin_y = min(y - margin_y, (1.0 - margin_y) - y);
    float distance_to_margin = min(distance_to_margin_x, distance_to_margin_y);

    float wall_noise = snoise(vec3(var_TexCoord * in_TextureSize * WALL_SPACING, in_Seed));
    float water_noise = snoise(vec3(var_TexCoord * in_TextureSize * WATER_SPACING, in_Seed));

    water_noise += 0.6;

    if(distance_to_margin < 0.0)
    {
        gl_FragColor = in_CavernWall;
    }
    else if(wall_noise > -0.15 && wall_noise < water_noise)
    {
        gl_FragColor = in_CavernFloor;
    }
    else if(wall_noise > water_noise)
    {
        gl_FragColor = vec4(0.0, 0.0, (0.8 - (wall_noise * 0.25)), 1.0);
    }
    else
    {
       gl_FragColor = in_CavernWall;
    }
}