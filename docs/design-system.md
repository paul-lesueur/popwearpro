# Popwear Pro — Charte / Design System

Référence visuelle partagée pour toute l'équipe. Valeurs **relevées dans l'inspecteur Figma** (design system officiel), sauf mentions « ≈ » (estimées, à confirmer). Stack cible : **Rails + Bootstrap 5 + SCSS** (template Le Wagon).

---

## 1. Couleurs

### Texte

| Token | Hex | Usage |
| :---- | :---- | :---- |
| `text-primary` | `#131523` | Titres (H1–H4) |
| `secondary` | `#411221` | Prune — titres de section, corps de texte, prix |
| `subtext` | `#8B82B0` ≈ | Lavande — sous-textes, initiales d'avatars, croix de modale |

### Marque — dégradés officiels

| Token | Valeur | Usage |
| :---- | :---- | :---- |
| `Main Gradient` (orange) | `#EE7635` → `#FF6342` (linéaire) | Bouton primaire, item de nav actif, badge « PRO » |
| `Alert Gradient` (vert) | `#00BA94` → `#49D825` (linéaire) | Boutons de validation (Finaliser / Enregistrer), succès, barres de graphe |
| `primary` (orange solide) | `#FF6342` | Bordure + texte des boutons outline, accents |

### États & surfaces

| Token | Hex | Usage |
| :---- | :---- | :---- |
| `success` | `#00BA88` | Succès |
| `warning` | `#F4AD22` | Pastilles horloge, badges « en attente » |
| `error` | `#E5484D` ≈ | Erreurs |
| `bg-page` | `#FCF8F8` | Fond de l'application (crème) |
| `bg-card` | `#FFFFFF` | Cards |
| `neutral-soft` | `#E6E9F4` | Fond de badge neutre (« En cours ») |
| `border` | `#EAE4DF` ≈ | Bordures, séparateurs |

---

## 2. Typographie — système à 2 polices

- **Titres (H1–H4)** : `League Spartan`, Bold
- **Corps / sub-headings / boutons / labels** : `Inter`

Poids : Regular 400 · Medium 500 · Semi-Bold 600 · Bold 700.

| Style | Police | Taille / Interligne | Poids |
| :---- | :---- | :---- | :---- |
| h1 | League Spartan | 40 / 48 | Bold |
| h2 | League Spartan | 32 / 40 | Bold |
| h3 | League Spartan | 24 / 32 | Bold |
| h4 | League Spartan | 20 / 28 | Bold |
| sub 1 | Inter | 20 / 28 | Medium |
| sub 2 | Inter | 16 / 24 | Medium |
| body 1 | Inter | 16 / 24 | Regular / Semi-Bold / Bold |
| body 2 | Inter | 14 / 24 | Regular / Semi-Bold |
| body 3 | Inter | 12 / 16 | Regular / Semi-Bold |

Import (Google Fonts) à placer dans le `<head>` :

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=League+Spartan:wght@700&display=swap" rel="stylesheet">
```

---

## 3. Formes

| Token | Valeur |
| :---- | :---- |
| Rayon d'angle (cards, boutons, inputs) | `12px` |
| Rayon « pill » (badges) | `999px` |
| Ombre de card | `0 4px 16px rgba(19,21,35,.06)` |

---

## 4. Composants

**Boutons** (radius 12)

- *Primaire* : fond `Main Gradient` (orange), texte blanc — actions « Créer… »
- *Outline* : fond blanc, bordure + texte `primary` — Annuler, Voir le détail, Ajouter…
- *Succès* : fond `Alert Gradient` (vert), texte blanc — Finaliser / Enregistrer

**Sidebar** : blanche, largeur ~240px. Logo « popwear » (League Spartan bold, `text-primary`) + pill « PRO » en `Main Gradient`. Item actif = fond `Main Gradient`, texte + icône blancs, radius 12.

**Header** : avatar rond + nom utilisateur + chevron → dropdown (contient la déconnexion).

**Flash / alertes** : card blanche radius 12 + ombre légère, dismissible. Succès → accent vert (`Alert Gradient`) ; erreur → `error`. Jamais le bleu Bootstrap par défaut.

**Cards** : fond blanc, radius 12, ombre `shadow-card`, sur fond de page crème.

**Badges de statut** : pill. Succès = vert pâle / texte vert ; neutre = `neutral-soft` / texte gris.

**Modale** : overlay noir ~50%, card blanche radius 12, titre `text-primary`, bouton primaire orange gradient + lien secondaire texte vert, croix en `subtext`.

**Toast succès** : card blanche, pastille check en `Alert Gradient`, titre `text-primary`, barre soulignée gradient vert.

---

## 5. Variables SCSS

À coller dans `app/assets/stylesheets/config/_colors.scss` / `_variables.scss` :

```scss
// ---- Texte ----
$text-primary: #131523;
$secondary:    #411221;
$subtext:      #8B82B0;

// ---- Marque (dégradés officiels) ----
$gradient-orange: linear-gradient(135deg, #EE7635 0%, #FF6342 100%); // Main Gradient
$gradient-green:  linear-gradient(135deg, #00BA94 0%, #49D825 100%); // Alert Gradient
$primary: #FF6342;

$success: #00BA88;
$warning: #F4AD22;
$error:   #E5484D;

// ---- Surfaces ----
$bg-page:      #FCF8F8;
$bg-card:      #FFFFFF;
$neutral-soft: #E6E9F4;
$border:       #EAE4DF;

// ---- Typo ----
$font-heading: 'League Spartan', sans-serif; // H1–H4 (Bold)
$font-body:    'Inter', sans-serif;          // corps, sub, boutons

// ---- Formes ----
$radius:       12px;
$radius-pill:  999px;
$shadow-card:  0 4px 16px rgba(19, 21, 35, .06);
```

Override Bootstrap (`app/assets/stylesheets/config/_bootstrap_variables.scss`) :

```scss
$primary:              #FF6342;
$success:              #00BA88;
$danger:               #E5484D;
$body-bg:              #FCF8F8;
$font-family-base:     'Inter', sans-serif;
$headings-font-family: 'League Spartan', sans-serif;
$border-radius:        12px;
```

---

*Charte dérivée des 5 écrans d'entrée + du Design System Figma « Le Wagon — Popwear Pro ». Les valeurs marquées « ≈ » restent à confirmer dans Figma.*
