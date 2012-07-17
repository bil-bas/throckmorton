#version 110

// Smooth the square edges of the tiles.

const vec2 TextureSize = vec2(1024.0, 1024.0); // Gosu-specific!
const vec2 PixelSize = 1.0 / TextureSize;

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.

varying vec2 var_TexCoord; // Pixel to process on this pass
varying vec4 var_Color;

void main()
{
    vec4 self = texture2D(in_Texture, var_TexCoord);
    vec4 right = texture2D(in_Texture, var_TexCoord + vec2(1, 0) * PixelSize);
    vec4 left = texture2D(in_Texture, var_TexCoord + vec2(-1, 0) * PixelSize);
    vec4 top = texture2D(in_Texture, var_TexCoord + vec2(0, 1) * PixelSize);
    vec4 bottom = texture2D(in_Texture, var_TexCoord + vec2(0, -1) * PixelSize);

    if(left != self && (left == top || left == bottom))
    {
        gl_FragColor = left;
    }
    else if(right != self && (right == top || right == bottom))
    {
        gl_FragColor = right;
    }
    else
    {
        gl_FragColor = texture2D(in_Texture, var_TexCoord);
    }
}