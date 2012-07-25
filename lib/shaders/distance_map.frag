#version 110

// Calculates a distance map, based on how far any pixel is from an opaque pixel.
// In each pixel, r/g/b = number of pixels from an opaque pixel.

uniform sampler2D in_Texture; // Original texture.

uniform vec2 in_TextureSize; // Width and height of the texture, so we know how big pixels are.
uniform int in_StepSize; // Distance to check each time (larger steps will be faster, but less accurate).
uniform int in_MaxDistance; // Maximum distance to search out to.

varying vec2 var_TexCoord; // Pixel to process on this pass.

const int NUM_SPOKES = 24; // Number of radiating lines to check in.
const int ANGULAR_STEP = 360 / NUM_SPOKES;

// Read in alpha at each of 8 points, around the center.
// Returns true if all of them are fully transparent.
bool clear_at_distance(in float x, in float y, in vec2 distance)
{
    for(int i = 0; i < 360; i += ANGULAR_STEP)
    {
        float angle = float(i);
        vec2 position = vec2(x + distance.x * cos(angle),
                             y + distance.y * sin(angle));

        if(texture2D(in_Texture, position).a > 0.0)
        {
           return false;
        }
    }

    return true;
}

void main()
{
    vec2 pixel_size = 1.0 / in_TextureSize;

    int distance = 0;

    if(texture2D(in_Texture, var_TexCoord).a == 0.0)
    {
        float x = var_TexCoord.x;
        float y = var_TexCoord.y;

        for(int i = in_StepSize; i <= in_MaxDistance; i += in_StepSize)
        {
            if(clear_at_distance(x, y, float(i) * pixel_size))
            {
                distance = i;
            }
            else
            {
                i = in_MaxDistance + 1; // BREAK!
            }
        }
    }

    gl_FragColor =  vec4(vec3(float(distance) / 255.0), 1.0);
}