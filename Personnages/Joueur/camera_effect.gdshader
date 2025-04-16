shader_type canvas_item;

// Déclaration explicite de la texture d'écran pour Godot 4
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Paramètres pour effet caméra backrooms
uniform float noise_amount : hint_range(0.0, 0.1) = 0.02;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float color_shift : hint_range(0.0, 0.01) = 0.002;
uniform float darkness : hint_range(0.0, 0.3) = 0.05;
uniform float static_strength : hint_range(0.0, 0.1) = 0.02;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    // Coordonnées UV standard
    vec2 uv = SCREEN_UV;

    // Vérifier si les coordonnées sont hors limites
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        // Échantillonnage avec un léger décalage des couleurs
        vec3 col;
        col.r = texture(screen_texture, vec2(uv.x + color_shift, uv.y)).r;
        col.g = texture(screen_texture, uv).g;
        col.b = texture(screen_texture, vec2(uv.x - color_shift, uv.y)).b;

        // Ajouter du bruit statique léger
        float noise = rand(uv + vec2(TIME * 0.1, 0.0)) * noise_amount;
        col += vec3(noise);

        // Effet de grain VHS/caméra ancienne
        float static_noise = rand(vec2(uv.y * 100.0 + TIME, uv.x * 100.0)) * static_strength;
        col += vec3(static_noise);

        // Vignette pour ambiance sombre
        float d = length(uv - 0.5) * 2.0;
        float vignette = 1.0 - d * d * vignette_intensity;
        col *= vignette; // Corrected: Multiply color by vignette

        // Assombrir légèrement
        col -= vec3(darkness);

        // Modifier légèrement les couleurs pour une ambiance jaunâtre/verdâtre (typique des backrooms)
        col = mix(col, vec3(1.0, 1.0, 0.85), 0.15);

        // Résultat final
        COLOR = vec4(col, 1.0);
    }
}