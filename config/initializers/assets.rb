# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join('vendor')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w(
    favicon/browserconfig.xml
    fontawesome-webfont.eot
    fontawesome-webfont.svg
    fontawesome-webfont.ttf
    fontawesome-webfont.woff
    fontawesome-webfont.woff2
    FontAwesome.otf
    Simple-Line-Icons.svg
    Simple-Line-Icons.eot
    Simple-Line-Icons.ttf
    Simple-Line-Icons.woff
    Simple-Line-Icons.woff2
    themify.eot
    themify.svg
    themify.ttf
    themify.woff
    bootstrap.min.css
    revolution/css/settings.css
    revolution/css/layers.css
    revolution/css/navigation.css
    magnific-popup.css
    jquery.mmenu.css 
    owl.carousel.min.css
    font-awesome.min.css.erb
    colors.css
    themify-icons.css
    simple-line-icons.css
    style.css
    assets/datatables.min.css
    assets/datatables.min.js
    pagination_evaluation.js
    responsive.css
    jquery-3.2.1.min.js
    bootstrap.min.js
    pagination.min.js
    jquery.ajaxchimp.js
    jquery.magnific-popup.min.js
    jquery.mmenu.js
    jquery.inview.min.js
    jquery.countTo.min.js
    jquery.countdown.min.js
    owl.carousel.min.js
    imagesloaded.pkgd.min.js
    isotope.pkgd.min.js
    headroom.js
    custom.js
    revolution/jquery.themepunch.tools.min.js
    revolution/jquery.themepunch.revolution.min.js
    revolution/revolution.extension.actions.min.js
    revolution/revolution.extension.carousel.min.js
    revolution/revolution.extension.kenburn.min.js
    revolution/revolution.extension.layeranimation.min.js
    revolution/revolution.extension.migration.min.js
    revolution/revolution.extension.navigation.min.js
    revolution/revolution.extension.parallax.min.js 
    revolution/revolution.extension.slideanims.min.js
    revolution/revolution.extension.video.min.js
)