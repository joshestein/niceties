
defmodule NicetiesWeb.GroupHTML do
  @moduledoc """
  This module contains pages rendered by GroupController.

  See the `group_html` directory for all templates available.
  """
  use NicetiesWeb, :html

  # embed_templates "group_html/*"

  def home(assigns) do
    ~H"""
    hello!
    """
  end

  def group(assigns) do
    ~H"""
    group {@id}
    """
  end
end
