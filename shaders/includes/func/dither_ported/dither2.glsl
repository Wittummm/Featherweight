// From [https://www.shadertoy.com/view/7sfXDn] 
// CREDIT: joshtheb(jbritain) https://discord.com/channels/237199950235041794/736928196162879510/1359165099344134338

float dither2(vec2 a) {
    a = floor(a);
    return fract(a.x / 2. + a.y * a.y * .75);
}

// #define Bayer4(a)   (Bayer2 (.5 *(a)) * .25 + Bayer2(a))
// #define Bayer8(a)   (Bayer4 (.5 *(a)) * .25 + Bayer2(a))
// #define Bayer16(a)  (Bayer8 (.5 *(a)) * .25 + Bayer2(a))
// #define Bayer32(a)  (Bayer16(.5 *(a)) * .25 + Bayer2(a))
// #define Bayer64(a)  (Bayer32(.5 *(a)) * .25 + Bayer2(a))