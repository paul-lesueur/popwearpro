module CatalogIconsHelper
  ICONS_DIR = Rails.root.join("app/assets/images/catalog-icons")
  @svg_cache = {}

  # Lit (et met en cache) la source SVG d'une icône du catalogue.
  def self.svg_source(key)
    key = key.to_s
    return nil if key.blank?

    @svg_cache.fetch(key) do
      path = ICONS_DIR.join("#{key}.svg")
      @svg_cache[key] = File.exist?(path) ? File.read(path).strip : nil
    end
  end

  # Icône inline, dans un halo (à utiliser dans les vues).
  # Le SVG porte sa propre couleur de trait ; on le dimensionne en CSS via .catalog-icon.
  def catalog_icon(key, css_class: "catalog-icon")
    svg = CatalogIconsHelper.svg_source(key)
    return "".html_safe if svg.nil?

    content_tag(:span, raw(svg), class: css_class)
  end

  # Source SVG brute (chaîne non html_safe) : pour passer le SVG dans un data-attribute
  # (Rails l'échappe automatiquement, le JS le réinjecte via innerHTML).
  def catalog_icon_source(key)
    CatalogIconsHelper.svg_source(key).to_s
  end
end
