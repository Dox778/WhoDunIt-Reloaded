// Use parallax mapping? (default 1)
// This makes textures appear to stick out quite a bit.
// Note that it's a bit costly since now the normal and tangents
// will be generated at all times without dynamic lights being around.
#define PARALLAX_MAP 1

// Strength of the parallax map. (default 0.05)
// Higher is stronger, but causes distortion.
// Of course, only does anything if PARALLAX_MAP is 1.
#define PARALLAX_SCALE 0.05

// Do a bilinear sample for the parallax map? (default 1)
// A little faster if not, but looks weird without filtering.
#define BILINEAR_PARALLAX_SAMPLE 1

// Change specular highlight strength. (default 32)
#define SPECULAR_FACTOR 256

// Disable specular highlights? (default off)
// This and PARALLAX_MAP 1 essentially makes this a parallax-only shader.
#define NO_SPECULAR 1

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
#define BTEX_SIZE 64.0

// Show calculated normal? Only really useful for debugging.
#define DEBUG_SHOW_NORMAL 0

// End of bump map options!

// Grayscale Bump Mapping + Parallax shader, by TDRR.
// Most of the code comes from here:
// https://www.geeks3d.com/20130122/normal-mapping-without-precomputed-tangent-space-vectors/
// with some optimization and other code from elsewhere.

// Parallax mapping code comes from dpJudas's (?) shader here.
// https://forum.zdoom.org/viewtopic.php?t=62104

// Since my grayscale bump map shader and normal map shader share almost all of
// their code, this is here to help keep them both in sync.
// NOTE: Normal map mode requires the shader to replace func_brightmap.fp!
#define NORMAL_MAP_MODE 0

#if NORMAL_MAP_MODE
	uniform sampler2D texture2;
#endif

#if ( (defined(DYNLIGHT) && !NO_SPECULAR) || PARALLAX_MAP) && defined(DOOMLIGHTFACTOR)

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

// https://community.khronos.org/t/manual-bilinear-filter/58504/3
float GetDisplacementAt(vec2 uv)
{
	#if BILINEAR_PARALLAX_SAMPLE
	const float texelSize = 1.0 / BTEX_SIZE;
	
    vec2 f = fract( uv * BTEX_SIZE );
    uv += ( .5 - f ) * texelSize;    // move uv to texel centre
    float tl = texture2D(tex, uv).a;
    float tr = texture2D(tex, uv + vec2(texelSize, 0.0)).a;
    float bl = texture2D(tex, uv + vec2(0.0, texelSize)).a;
    float br = texture2D(tex, uv + texelSize, texelSize).a;
    float tA = mix( tl, tr, f.x );
    float tB = mix( bl, br, f.x );
    return 0.5 - mix( tA, tB, f.y );
	#else
	return 0.5 - texture2D(tex, uv).a;
	#endif
}

#if PARALLAX_MAP
vec2 ParallaxMap(mat3 tbn, vec2 texCoords)
{
    // Calculate fragment view direction in tangent space
    mat3 invTBN = transpose(tbn);
    vec3 V = normalize(invTBN * (camerapos.xyz - pixelpos.xyz));

    vec2 p = V.xy / abs(V.z) * GetDisplacementAt(texCoords) * PARALLAX_SCALE;
    return texCoords - p;
}
#endif

#if defined(DYNLIGHT) && !NO_SPECULAR

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
		
		normal.x = (-normal.x) + 1.0;
		
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

#endif // defined(DYNLIGHT) && !NO_SPECULAR

vec4 Process(vec4 color)
{	
	vec2 UV = gl_TexCoord[0].st;
	
	vec3 dFd_x = dFdx(pixelpos.xyz);
	vec3 dFd_y = dFdy(pixelpos.xyz);
	
	vec3 polynormal = normalize(cross(dFd_x, dFd_y));
	
	mat3 TBN = cotangent_frame(polynormal, UV, dFd_x, dFd_y);
	
	#if PARALLAX_MAP
		UV = ParallaxMap(TBN, UV);
	#endif
	
	vec4 texel = texture2D(tex, UV);
	
	if(texel.a <= 0.02)
		return vec4(0.0, 0.0, 0.0, 0.0);
	
	#if (!defined(DYNLIGHT)) || (NO_SPECULAR)
		return vec4(texel.rgb * color.rgb, color.a);
	#else // (!defined(DYNLIGHT)) || (NO_SPECULAR)
	
	vec3 eyedir = normalize(camerapos.xyz - pixelpos.xyz);
	vec3 normal = getNormalFromBumpMap(UV);
	
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
	
	#endif // (!defined(DYNLIGHT)) || (NO_SPECULAR)
}

#else

vec4 Process (vec4 color)
{
	return vec4(getTexel(gl_TexCoord[0].st) * color.rgb, color.a);
}

#endif