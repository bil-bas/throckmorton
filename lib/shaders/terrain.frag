#version 110

#include <noise4D>

const float CF_MICRO_STEP = 0.5;
const float CF_MIDI_STEP = 0.1;
const float CF_MACRO_STEP = 0.0028;
const float CF_MOSS_STEP = 0.005;

const float CW_MICRO_STEP = 0.3;
const float CW_MACRO_STEP = 0.02;

const float L_CRUST_MACRO_STEP = 0.09;
const float L_CRUST_MICRO_STEP = 0.5;
const float L_LAVA_STEP = 0.1;

const float W_WATER_STEP = 0.15;
const float W_ROCKS_STEP = 0.25;

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
uniform vec4 in_CavernFloor;
uniform vec4 in_CavernWall;
uniform vec4 in_Lava;
uniform int in_Seed;
uniform float in_Time;
uniform vec2 in_TextureSize;

varying vec2 var_TexCoord; // Pixel to process on this pass
varying vec4 var_Color;

void main()
{
    vec4 color = texture2D(in_Texture, var_TexCoord);

    // Pixelate.
    vec2 coord = vec2(ivec2(var_TexCoord * in_TextureSize)) / in_TextureSize;

    if(color == in_CavernFloor)
    {
        // CAVERN FLOOR
        float micro_noise = snoise(vec4(coord * CF_MICRO_STEP * in_TextureSize, 0, in_Seed));
        float midi_noise = snoise(vec4(coord * CF_MIDI_STEP * in_TextureSize, 0, in_Seed));
        float macro_noise = snoise(vec4(coord * CF_MACRO_STEP * in_TextureSize, 0, in_Seed));
        float moss_noise = snoise(vec4(coord * CF_MOSS_STEP * in_TextureSize, 0, in_Seed));

        color.rgb += micro_noise * 0.015 +
                     midi_noise * -macro_noise * 0.08 +
                     macro_noise * -0.1;

        if(moss_noise > macro_noise + 0.4)
        {
           color.r += moss_noise * -0.5 * (micro_noise + 0.5);
           color.b += moss_noise * -0.3 * (micro_noise + 0.5);
        }
    }
    else if(color == in_CavernWall)
    {
        // CAVERN WALL
        float macro_noise = snoise(vec4(coord * CW_MACRO_STEP * in_TextureSize, 0, in_Seed));
        float micro_noise = snoise(vec4(coord * CW_MICRO_STEP * in_TextureSize, 0, in_Seed));

        color.rgb += (macro_noise * 0.1) - (micro_noise * 0.15);
    }
    else if(color.r == 0.0 && color.g == 0.0 && color.b > 0.0)
    {
        // WATER
        float ripple_noise = snoise(vec4(coord * W_WATER_STEP * in_TextureSize, in_Time * 0.8, in_Seed));
        float rock_noise = snoise(vec4(coord * W_ROCKS_STEP * in_TextureSize, 0, in_Seed));

        color.b -= ripple_noise * 0.05;
        color.r = color.b * 0.15;
        color.g = color.b * 0.6;

        if(rock_noise > 0.0)
        {
            //color.g += rock_noise * -0.2;
            //color.b += rock_noise * -0.2;
        }
    }
    else if(color == in_Lava)
    {
        // LAVA
        float crust_micro_noise = snoise(vec4(coord * L_CRUST_MICRO_STEP * in_TextureSize, 0, in_Seed));
        float crust_macro_noise = snoise(vec4(coord * L_CRUST_MACRO_STEP * in_TextureSize, 0, in_Seed));

        float lava_noise = snoise(vec4(coord * L_LAVA_STEP * in_TextureSize, in_Time * 0.2, in_Seed));

        if(crust_macro_noise > 0.0)
        {
            float crust_noise = (crust_macro_noise * 0.7) + (crust_micro_noise * 0.3);
            color.rgb = vec3(crust_noise * 0.5, crust_noise * 0.4, crust_noise * 0.35);
        }
        else
        {
            color.rgb += vec3(lava_noise * 0.1, lava_noise * 0.2, lava_noise * 0.02);
        }
    }

    gl_FragColor = color;
}