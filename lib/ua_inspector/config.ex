defmodule UAInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  @doc """
  Provides access to configuration values with optional environment lookup.
  """
  @spec get(atom | list, term) :: term
  def get(key, default \\ nil)

  def get(key, default) when is_atom(key) do
    :ua_inspector
    |> Application.get_env(key, default)
    |> maybe_fetch_system()
  end

  def get(keys, default) when is_list(keys) do
    :ua_inspector
    |> Application.get_all_env()
    |> Kernel.get_in(keys)
    |> maybe_use_default(default)
    |> maybe_fetch_system()
  end

  @doc """
  Returns the configured database path or `nil`.
  """
  @spec database_path :: String.t | nil
  def database_path do
    case get(:database_path) do
      nil  -> nil
      path -> Path.expand(path)
    end
  end


  defp maybe_fetch_system(config) when is_list(config) do
    Enum.map config, fn
      { k, v } -> { k, maybe_fetch_system(v) }
      other    -> other
    end
  end

  defp maybe_fetch_system({ :system, var }), do: System.get_env(var)
  defp maybe_fetch_system(config),           do: config

  defp maybe_use_default(nil,    default), do: default
  defp maybe_use_default(config, _),       do: config
end
