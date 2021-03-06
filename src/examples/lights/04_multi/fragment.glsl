precision highp float;

varying vec3 v_viewSurfacePosition;
varying vec3 v_viewSurfaceNormal;
varying vec2 v_uv0;

#define MAX_PUNCTUAL_LIGHTS 10
uniform int numPunctualLights;
uniform int punctualLightType[MAX_PUNCTUAL_LIGHTS];
uniform vec3 punctualLightViewPosition[MAX_PUNCTUAL_LIGHTS];
uniform vec3 punctualLightViewDirection[MAX_PUNCTUAL_LIGHTS];
uniform vec3 punctualLightColor[MAX_PUNCTUAL_LIGHTS];
uniform float punctualLightRange[MAX_PUNCTUAL_LIGHTS];
uniform float punctualLightInnerCos[MAX_PUNCTUAL_LIGHTS];
uniform float punctualLightOuterCos[MAX_PUNCTUAL_LIGHTS];

uniform sampler2D albedoMap;

#pragma include <brdfs/common>
#pragma include <lighting/punctual>
#pragma include <brdfs/ambient/basic>
#pragma include <brdfs/diffuse/lambert>
#pragma include <brdfs/specular/ggx>
#pragma include <color/spaces/srgb>
#pragma include <normals/packing>

void main() {

  vec3 albedo = sRGBToLinear( texture2D(albedoMap, v_uv0).rgb );
  vec3 specular = vec3(.5);
  float specularRoughness = .25;
  vec3 specularF0 = specularIntensityToF0( specular );

  Surface surface;
  surface.position = v_viewSurfacePosition;
  surface.normal = normalize( v_viewSurfaceNormal );
  surface.viewDirection = normalize( -v_viewSurfacePosition );

  uvToTangentFrame( surface, v_uv0 );

  vec3 outputColor;

  for( int i = 0; i < MAX_PUNCTUAL_LIGHTS; i ++ ) {

    PunctualLight punctualLight;
    punctualLight.type = punctualLightType[i];
    punctualLight.position = punctualLightViewPosition[i];
    punctualLight.direction = punctualLightViewDirection[i];
    punctualLight.color = punctualLightColor[i];
    punctualLight.range = punctualLightRange[i];
    punctualLight.innerConeCos = punctualLightInnerCos[i];
    punctualLight.outerConeCos = punctualLightOuterCos[i];

    DirectIrradiance directIrradiance;
    if( punctualLight.type == 0 ) {
      pointLightToDirectIrradiance( surface, punctualLight, directIrradiance );
    }
    if( punctualLight.type == 1 ) {
      spotLightToDirectIrradiance( surface, punctualLight, directIrradiance );
    }
    if( punctualLight.type == 2 ) {
      directionalLightToDirectIrradiance( surface, punctualLight, directIrradiance );
    }

    vec3 lightDirection = directIrradiance.lightDirection;
    vec3 irradiance = directIrradiance.irradiance;

    outputColor += irradiance * BRDF_Specular_GGX( surface, lightDirection, specularF0, specularRoughness );
    outputColor += irradiance * BRDF_Diffuse_Lambert( albedo );

    if( i >= numPunctualLights ) break;

  }

  gl_FragColor.rgb = linearTosRGB( outputColor );
  gl_FragColor.a = 1.;

}
