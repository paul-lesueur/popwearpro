# Police Unicode pour les reçus PDF : Helvetica (AFM, par défaut dans Prawn) ne
# gère ni les accents français ni le symbole €. On force DejaVu Sans (vendorée
# dans vendor/fonts), portable en production.
font_dir = Rails.root.join("vendor", "fonts")

Receipts.default_font = {
  normal:      font_dir.join("DejaVuSans.ttf").to_s,
  bold:        font_dir.join("DejaVuSans-Bold.ttf").to_s,
  italic:      font_dir.join("DejaVuSans.ttf").to_s,
  bold_italic: font_dir.join("DejaVuSans-Bold.ttf").to_s
}

# Plus de police AFM utilisée : on coupe l'avertissement m17n de Prawn.
Prawn::Fonts::AFM.hide_m17n_warning = true
