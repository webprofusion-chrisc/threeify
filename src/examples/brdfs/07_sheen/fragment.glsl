precision highp float;

varying vec3 v_viewSurfacePosition;
varying vec3 v_viewSurfaceNormal;
varying vec2 v_uv0;

uniform vec3 pointLightViewPosition;
uniform vec3 pointLightColor;
uniform float pointLightRange;

uniform vec3 sheenColor;
uniform float sheenIntensity;
uniform float sheenRoughness;

#pragma include <brdfs/common>
#pragma include <lighting/punctual>
#pragma include <brdfs/ambient/basic>
#pragma include <brdfs/diffuse/lambert>
#pragma include <brdfs/specular/ggx>
#pragma include <brdfs/sheen/charlie>
#pragma include <color/spaces/srgb>

void main() {

  vec3 albedo = vec3( 0., 0., 1. );
  vec3 specular = vec3(0.15);
  float specularRoughness = 0.5;
  vec3 specularF0 = specularIntensityToF0( specular );

  Surface surface;
  surface.position = v_viewSurfacePosition;
  surface.normal = normalize( v_viewSurfaceNormal );
  surface.viewDirection = normalize( -v_viewSurfacePosition );

  uvToTangentFrame( surface, v_uv0 );

  PunctualLight punctualLight;
  punctualLight.position = pointLightViewPosition;
  punctualLight.color = pointLightColor;
  punctualLight.range = pointLightRange;

  DirectIrradiance directIrradiance;
  pointLightToDirectIrradiance( surface, punctualLight, directIrradiance );

  vec3 lightDirection = directIrradiance.lightDirection;
  vec3 irradiance = directIrradiance.irradiance;

  vec3 outputColor;
  outputColor += irradiance * BRDF_Sheen_Charlie( surface, lightDirection, sheenColor, sheenIntensity, sheenRoughness );
  outputColor += (1. - sheenIntensity ) * irradiance * BRDF_Specular_GGX( surface, lightDirection, specularF0, specularRoughness );
  outputColor += irradiance * BRDF_Diffuse_Lambert( albedo );

  gl_FragColor.rgb = linearTosRGB( outputColor );
  gl_FragColor.a = 1.;

}
