defmodule Newnix.Providers do
  alias Newnix.Projects.Integration.Config

  def get_active_prodivders() do
    Config.get_providers()
  end

  def input_config_required?(provider, field_name) do
    field_name in Config.get_provider_fields(provider)
  end
end
