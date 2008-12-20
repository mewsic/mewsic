module SitemapHelper
  def sitemap_path_for(page, *args)
    sitemap_root_path + send("#{page}_path", *args)
  end

  def sitemap_root_path
    APPLICATION[:url]
  end
end
