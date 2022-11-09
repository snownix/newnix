defmodule NewnixWeb.Plugs.SetLocale do
  import Plug.Conn

  @supported_locales Gettext.known_locales(NewnixWeb.Gettext)

  def init(_options), do: nil

  def call(conn, _options) do
    conn |> set_locale_to(fetch_locale_from(conn))
  end

  defp fetch_locale_from(%{params: params, cookies: cookies} = conn) do
    (params["locale"] || cookies["locale"] || get_session(conn, :locale))
    |> check_locale
  end

  defp set_locale_to(conn, nil) do
    set_locale_to(conn, "en")
  end

  defp set_locale_to(conn, locale) do
    NewnixWeb.Gettext |> Gettext.put_locale(locale)

    conn = conn |> put_session(:locale, locale)
    put_resp_cookie(conn, "locale", locale)
  end

  defp check_locale(locale) when locale in @supported_locales, do: locale
  defp check_locale(_), do: nil
end
