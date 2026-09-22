#version 460 core

// Eau du bassin, vue d'en haut.
//
// Un dégradé de profondeur, deux ondulations lentes qui se croisent, et des
// caustiques — ces filets de lumière que le soleil dessine au fond d'une eau
// qui bouge. Tout est calculé par pixel, sans texture : rien à charger, et
// le rendu suit les couleurs du thème.
//
// Contraintes Flutter : pas d'entier non signé ni de booléen, uniforms lus
// dans l'ordre de déclaration côté Dart (index 0 = uResolution.x).

#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform vec3 uColorShallow;
uniform vec3 uColorDeep;
uniform float uCausticIntensity;
uniform float uWaveAmplitude;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uResolution;

  // Le fond descend vers le bas de l'écran et vers le centre : on regarde un
  // bassin creusé, pas une flaque.
  float toCenter = length(uv - vec2(0.5, 0.62));
  float depth = clamp(uv.y * 0.55 + 0.20 + toCenter * 0.35, 0.0, 1.0);
  vec3 color = mix(uColorShallow, uColorDeep, depth);

  float t = uTime;

  // Deux trains d'ondes obliques, de fréquences différentes : leur somme ne
  // se répète jamais visiblement.
  float wave1 = sin((uv.x * 6.0 + uv.y * 4.0) * 3.14159 + t * 0.80);
  float wave2 = sin((uv.x * 3.0 - uv.y * 7.0) * 3.14159 - t * 0.55);
  float ripple = (wave1 + wave2) * 0.5 * uWaveAmplitude;

  // Caustiques : deux sinusoïdes déformées l'une par l'autre, élevées à la
  // puissance pour ne garder que les crêtes — des filaments, pas un damier.
  float c1 = sin(uv.x * 22.0 + t * 0.9 + sin(uv.y * 9.0 + t * 0.4) * 2.0);
  float c2 = sin(uv.y * 18.0 - t * 0.7 + sin(uv.x * 11.0 - t * 0.5) * 2.0);
  float caustic = pow(max(0.0, c1 * c2), 3.0) * uCausticIntensity;

  // La lumière porte moins au fond : les caustiques s'estompent avec la
  // profondeur.
  color += ripple * 0.05 + caustic * (1.0 - depth * 0.65);

  fragColor = vec4(color, 1.0);
}
