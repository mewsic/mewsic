module AvatarsHelper
  def avatar_path(model, size)
    model.avatar.nil? ? "default_avatars/avatar_#{size}.gif" : model.avatar.public_filename(size)
  end

  def avatar_image(model, size, options = {})
    path = avatar_path(model, size)
    options = {:id => "avatar_#{model.avatar.id}"}.merge(options) unless model.avatar.nil?
    options.update(:alt => model.to_breadcrumb, :title => model.to_breadcrumb) if model.respond_to? :to_breadcrumb
    image_tag path, options
  end
end
