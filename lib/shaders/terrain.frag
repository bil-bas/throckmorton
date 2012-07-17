#version 110

#include <noise4D>

// Smooth the square edges of the tiles.

const vec2 TextureSize = vec2(1024.0, 1024.0); // Gosu-specific!
const vec2 PixelSize = 1.0 / TextureSize;

const float CF_MICRO_STEP = 0.5 * TextureSize.x;
const float CF_MIDI_STEP = 0.1 * TextureSize.x;
const float CF_MACRO_STEP = 0.0007 * TextureSize.x;
const float CF_MOSS_STEP = 0.005 * TextureSize.x;

const float CW_MICRO_STEP = 0.3 * TextureSize.x;
const float CW_MACRO_STEP = 0.02 * TextureSize.x;

const float L_CRUST_MACRO_STEP = 0.09 * TextureSize.x;
const float L_CRUST_MICRO_STEP = 0.5 * TextureSize.x;
const float L_LAVA_STEP = 0.1 * TextureSize.x;

const float W_WATER_STEP = 0.04 * TextureSize.x;
const float W_ROCKS_STEP = 0.2 * TextureSize.x;

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
uniform vec4 in_CavernFloor;
uniform vec4 in_CavernWall;
uniform vec4 in_Water;
uniform vec4 in_Lava;
uniform int in_Seed;
uniform float in_Time;

varying vec2 var_TexCoord; // Pixel to process on this pass
varying vec4 var_Color;

void main()
{
    // Pixelate slightly.
//    vec2 TexCoord = vec2(ivec2((var_TexCoord + PixelSize * 0.5) * TextureSize * 0.5)) /
//                    (TextureSize * 0.5 - PixelSize * 0.5);
    vec2 TexCoord = var_TexCoord;
    vec4 color = texture2D(in_Texture, TexCoord);

    if(color == in_CavernFloor)
    {
        // CAVERN FLOOR
        float micro_noise = snoise(vec4(TexCoord * CF_MICRO_STEP, 0, in_Seed));
        float midi_noise = snoise(vec4(TexCoord * CF_MIDI_STEP, 0, in_Seed));
        float macro_noise = snoise(vec4(TexCoord * CF_MACRO_STEP, 0, in_Seed));
        float moss_noise = snoise(vec4(TexCoord * CF_MOSS_STEP, 0, in_Seed));

        color.rgb += micro_noise * 0.015 +
                     midi_noise * -macro_noise * 0.08 +
                     macro_noise * -0.2;

        if(moss_noise > macro_noise + 0.4)
        {
           color.r += moss_noise * -0.5 * (micro_noise + 0.5);
           color.b += moss_noise * -0.3 * (micro_noise + 0.5);
        }
    }
    else if(color == in_CavernWall)
    {
        // CAVERN WALL
        float macro_noise = snoise(vec4(TexCoord * CW_MACRO_STEP, 0, in_Seed));
        float micro_noise = snoise(vec4(TexCoord * CW_MICRO_STEP, 0, in_Seed));

        color.rgb += (macro_noise * 0.1) - (micro_noise * 0.15);
    }
    else if(color == in_Water)
    {
        // WATER
        float ripple_noise = snoise(vec4(TexCoord * W_WATER_STEP, in_Time * 0.2, in_Seed));
        float rock_noise = snoise(vec4(TexCoord * W_ROCKS_STEP, 0, in_Seed));

        color.rgb -= ripple_noise * 0.1;

        color.g += rock_noise * 0.05;
        color.b += rock_noise * 0.1;
    }
    else if(color == in_Lava)
    {
        // LAVA
        float crust_micro_noise = snoise(vec4(TexCoord * L_CRUST_MICRO_STEP, 0, in_Seed));
        float crust_macro_noise = snoise(vec4(TexCoord * L_CRUST_MACRO_STEP, 0, in_Seed));

        float lava_noise = snoise(vec4(TexCoord * L_LAVA_STEP, in_Time * 0.2, in_Seed));

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
    else
    {
        color = vec4(0.0, 0.0, 0.0, 1.0);
    }

    gl_FragColor = color;
}