# Development - Physique du kart

## Définitions :

**Velocity angle** :

- Initialisé, lors de la frame 1 du hop, à la direction courante vers où pointe le nez du kart
- Sinon, contient l'angle de la direction vers laquelle le kart se déplace

**Heading angle** : Direction courante vers où pointe le nez du kart

**Slip angle** :

- Angle de dérive entre le velocity_angle et le heading_angle

## Déviation interieur lors d'un drift

```
velocity_angle = lerp_angle(velocity_angle, heading_angle, 1.0 - exp(-drift_grip * delta))
```

- `exp(-drift_grip * delta)` donne la part de l’écart qu’on veut conserver après un pas de physique.
- `1.0 -` convertit cette part en écart à rattraper. S’il reste 95 %, on avance de 5 %.
- Pourquoi l’exponentielle ? Parce que les fractions restantes se multiplient. Deux pas de durée delta laissent `exp(-grip * delta) × exp(-grip * delta)`, soit exactement `exp(-grip * 2 * delta)`
- **Pour une cible fixe, deux petits pas donnent donc le même résultat qu’un grand pas de même durée.**

- Tant que heading_angle reste fixe, tu obtiens ainsi le même rapprochement sur la même durée, que Godot la découpe en un grand pas ou en deux petits.
- L’exponentielle fait en sorte qu’un seul pas deux fois plus long laisse lui aussi 81 % de l’écart.
- La propriété qui permet ça est `exp(a + a) = exp(a) × exp(a)`. Ici, `a = -drift_grip * delta`, donc doubler delta revient à appliquer deux fois la même fraction restante.

- Cours Godot utilisant `exp` pour ce genre de cas : https://docs.godotengine.org/en/4.6/tutorials/math/interpolation.html#smoothing-motion

## Misc. refs

- https://wassimulator.com/blog/programming-vehicles-in-games#tire
- https://backend.production.deepblue-documents.lib.umich.edu/server/api/core/bitstreams/e944fcae-91b9-477c-b82d-39c4e9ecd93b/content
