defmodule Params.Schema do

  defp __use__(:ecto) do
    quote do
      require Ecto.Schema
      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: false}
      @timestamps_opts []
      @foreign_key_type :binary_id
      @before_compile Ecto.Schema

      Module.register_attribute(__MODULE__, :ecto_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_assocs, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_embeds, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_raw, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_autogenerate_insert, accumulate: true)
      Module.register_attribute(__MODULE__, :ecto_autogenerate_update, accumulate: true)
      Module.put_attribute(__MODULE__, :ecto_autogenerate_id, nil)
    end
  end

  defp __use__(:params) do
    quote do
      Module.register_attribute(__MODULE__, :required, persist: true)
      Module.register_attribute(__MODULE__, :optional, persist: true)

      def from(params, changeset_name \\ :changeset) do
        ch = %{__struct__: __MODULE__} |> Ecto.Changeset.change
        apply(__MODULE__, changeset_name, [ch, params])
      end

      def changes(params, changeset_name \\ :changeset) do
        from(params, changeset_name) |> Params.changes
      end

      def model(params, changeset_name \\ :changeset) do
        from(params, changeset_name) |> Params.model
      end

      def changeset(changeset, params) do
        Params.changeset(changeset, params, :changeset)
      end

      defoverridable [changeset: 2]

    end
  end

  defmacro __using__([]) do
    quote do
      import Params.Schema, only: [schema: 1]
      unquote(__use__(:ecto))
      unquote(__use__(:params))
    end
  end

  defmacro __using__({:%{}, _, _} = schema) do
    Params.Def.defschema_at(schema, __CALLER__)
  end

  defmacro schema([do: definition]) do
    quote do
      Ecto.Schema.schema "params #{__MODULE__}" do
        unquote(definition)
      end
    end
  end

end
