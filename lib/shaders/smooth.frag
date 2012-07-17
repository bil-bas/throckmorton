#version 110

// Smooth the square edges of the tiles.

uniform sampler2D in_Texture; // Original texture.
uniform vec2 in_TextureSize; // Width and height of the texture, so we know how big pixels are.

varying vec2 var_TexCoord; // Pixel to process on this pass.

void main()
{
    vec2 pixel_size = 1.0 / in_TextureSize;

    vec4 self = texture2D(in_Texture, var_TexCoord);
    vec4 right = texture2D(in_Texture, var_TexCoord + vec2(1, 0) * pixel_size);
    vec4 left = texture2D(in_Texture, var_TexCoord + vec2(-1, 0) * pixel_size);
    vec4 top = texture2D(in_Texture, var_TexCoord + vec2(0, 1) * pixel_size);
    vec4 bottom = texture2D(in_Texture, var_TexCoord + vec2(0, -1) * pixel_size);

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