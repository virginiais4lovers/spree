class ProductsController < Spree::BaseController

  before_filter :load_product, :only => [:show]

  HTTP_REFERER_REGEXP = /^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/

  helper :taxons

  def show
    @variants = Variant.active.find_all_by_product_id(@product.id, :include => [:option_values, :images])
    @product_properties = ProductProperty.find_all_by_product_id(@product.id, :include => [:property])
    @selected_variant = @variants.detect { |v| v.available? }
    referer = request.env['HTTP_REFERER']
    @taxon = Taxon.find_by_permalink($1) if referer && referer.match(HTTP_REFERER_REGEXP)
  end

  def index
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products
  end

  private

  def accurate_title
    @product ? @product.name : nil
  end

  def load_product
    @product = Product.find_by_permalink!(params[:id])
  end

end
