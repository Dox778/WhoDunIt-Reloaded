// Change specular highlight strength. (default 32) //higher results in a weaker reflection
#define SPECULAR_FACTOR 16

// Allow the specular highlight to extend past the light size?
// May cause highlights to appear and dissapear abruptly in certain circumstances
// but overall gives a more "dramatic" effect.
// Default 1, (on, can extend past the light size)
#define EXTEND_SPECULAR 1

// Specular highlight range multiplier. Only does anything with the above option.
// Default 1.15, (1.15 times the base light range)
#define EXTEND_FACTOR 1.15

// Size of the texture to be sampled as a bump map. Not necessary, mostly just to
// help with nearest neighbor filtering and nasty "banding" artifacts.
#define BTEX_SIZE 64

// No translucency? If on, 0 alpha is repurposed as "no specular highlight"
#define NO_XLU 0

// Show calculated normal? Only really useful for debugging.
#define DEBUG_SHOW_NORMAL 0

// End of bump map options!

// Grayscale Bump Mapping shader, by TDRR.
// Most of the code comes from here:
// https://www.geeks3d.com/20130122/normal-mapping-without-precomputed-tangent-space-vectors/
// with some optimization and other code from elsewhere.

// Since my grayscale bump map shader and normal map shader share almost all of
// their code, this is here to help keep them both in sync.
// NOTE: Normal map mode requires the shader to replace func_brightmap.fp!
#define NORMAL_MAP_MODE 0

#if NORMAL_MAP_MODE
	uniform sampler2D texture2;
#endif

#ifdef DYNLIGHT

vec3 specularity (vec3 lightPos, vec3 viewDir, vec3 normal, vec3 color)
{	
	vec3 lightDir = normalize(lightPos - pixelpos.xyz);  
	
	vec3 reflectDir = reflect(-lightDir, normal);
	
	vec3 spec = vec3(pow(max(dot(viewDir, reflectDir), 0.0), SPECULAR_FACTOR));
	return spec * color;
}

vec3 getNormalFromBumpMap (vec2 tex_coord)
{
	#if NORMAL_MAP_MODE
		vec3 normal = texture2D(texture2, tex_coord).rgb;
	
		return normalize(normal * 2.0 - 1.0);
	#else
		const vec3 offset = vec3(-1.0/BTEX_SIZE, 0.0, 1.0/BTEX_SIZE);
		
		float L = texture2D(tex, tex_coord + offset.xy).a;
		float R = texture2D(tex, tex_coord + offset.zy).a;
		float T = texture2D(tex, tex_coord + offset.yz).a;
		float B = texture2D(tex, tex_coord + offset.yx).a;
		
		vec3 normal = normalize(vec3(4*(R-L), 4*(B-T), 4));
		
		return vec3(normal.x, -normal.y, normal.z);
	#endif
}

mat3 cotangent_frame(vec3 N, vec2 uv, vec3 dp1, vec3 dp2)
{
	// get edge vectors of the pixel triangle
	vec2 duv1 = dFdx( uv );
	vec2 duv2 = dFdy( uv );
	
	// solve the linear system
	vec3 dp2perp = cross( dp2, N );
	vec3 dp1perp = cross( N, dp1 );
	vec3 t = dp2perp * duv1.x + dp1perp * duv2.x;
	vec3 b = dp2perp * duv1.y + dp1perp * duv2.y;
 
    // construct a scale-invariant frame 
    float invmax = inversesqrt( max( dot(t,t), dot(b,b) ) );
    return mat3( t * invmax, b * invmax, N );
}

vec4 Process(vec4 color)
{	
	vec2 UV = gl_TexCoord[0].st;
	vec4 texel = texture2D(tex, UV);
	
	#if NO_XLU
		if(texel.a == 0.0)
			return vec4(texel.rgb * color.rgb, color.a);
	#else
		if(texel.a == 0.0)
			return vec4(0.0, 0.0, 0.0, 0.0);
	#endif
	
	//these are used later to calculate the tangents in the non-FAST_MODE
	//version, so to save some time they're stored.
	vec3 dFd_x = dFdx(pixelpos.xyz);
	vec3 dFd_y = dFdy(pixelpos.xyz);
	
	vec3 polynormal = normalize(cross(dFd_x, dFd_y));
	
	vec3 eyedir = normalize(camerapos.xyz - pixelpos.xyz);
	vec3 normal = getNormalFromBumpMap(UV);
	
	//perturb normal with generated tangent matrix
	mat3 TBN = cotangent_frame(polynormal, UV, dFd_x, dFd_y);
	normal = normalize(TBN * normal);
	
	vec3 spec = vec3(0.0);
	
	for(int i=0; i<lightrange.x; i+=2)
	{
		vec4 lightpos = lights[i];
		vec4 lightcolor = lights[i+1];
		
		#if EXTEND_SPECULAR
			lightpos.w *= EXTEND_FACTOR;
		#endif
		
		lightcolor.rgb *= max(lightpos.w - distance(pixelpos.xyz, lightpos.xyz),0.0) / lightpos.w;
		
		spec += specularity(lightpos.xyz, eyedir, normal, lightcolor.rgb);
	}
	
	#if DEBUG_SHOW_NORMAL
		return vec4(normal * 0.5 + 0.5, 1.0);
	#else
		return vec4( (texel.rgb * color.rgb) + spec, color.a);
	#endif
}

#else

vec4 Process (vec4 color)
{
	return vec4(getTexel(gl_TexCoord[0].st) * color.rgb, color.a);
}

#endif