// SOURCE: https://github.com/Zackin5/Filmic-Tonemapping-ReShade/blob/master/Hejl2015.fx

vec3 hejl(vec3 color) {
	vec3 va = (1.425 * color) + 0.05;
	vec3 vf = ((color * va + 0.004) / ((color * (va + 0.55) + 0.0491))) - 0.0821;

    return vf;
}