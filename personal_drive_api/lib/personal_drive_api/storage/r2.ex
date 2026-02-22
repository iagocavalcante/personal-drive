defmodule PersonalDriveApi.Storage.R2 do
  @moduledoc """
  R2 Cloudflare Storage service for file operations.
  """
  require Logger

  alias ExAws.S3
  alias PersonalDriveApi.Storage.Files

  @bucket Application.compile_env(:personal_drive_api, :r2)[:bucket]
  @public_url Application.compile_env(:personal_drive_api, :r2)[:public_url]

  @doc """
  Upload a file to R2 storage.
  """
  def upload_file(file_path, key) do
    Logger.info("Uploading file to R2: #{key}")

    case S3.put_object(@bucket, key, File.read!(file_path)) |> ExAws.request() do
      {:ok, result} ->
        etag = get_etag(result)
        {:ok, %{r2_key: key, r2_etag: etag}}

      {:error, error} ->
        Logger.error("R2 upload error: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Upload a file from a binary directly to R2 storage.
  """
  def upload_binary(binary, key, content_type) do
    Logger.info("Uploading binary to R2: #{key}")

    case S3.put_object(@bucket, key, binary, content_type: content_type) |> ExAws.request() do
      {:ok, result} ->
        etag = get_etag(result)
        {:ok, %{r2_key: key, r2_etag: etag}}

      {:error, error} ->
        Logger.error("R2 upload error: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Delete a file from R2 storage.
  """
  def delete_file(key) do
    Logger.info("Deleting file from R2: #{key}")

    case S3.delete_object(@bucket, key) |> ExAws.request() do
      {:ok, _result} ->
        {:ok, :deleted}

      {:error, error} ->
        Logger.error("R2 delete error: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Get a signed URL for downloading a file.
  """
  def get_signed_url(key, expires_in \\ 3600) do
    case S3.presigned_url(ExAws.Config.new(:s3), :get, @bucket, key, expires_in: expires_in) do
      {:ok, url} ->
        {:ok, url}

      {:error, error} ->
        Logger.error("R2 signed URL error: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Get the public URL for a file.
  """
  def get_public_url(key) do
    "#{@public_url}/#{key}"
  end

  @doc """
  Get a signed URL for uploading a file (for direct browser uploads).
  """
  def get_upload_url(key, content_type, expires_in \\ 3600) do
    case S3.presigned_url(ExAws.Config.new(:s3), :put, @bucket, key, expires_in: expires_in, content_type: content_type) do
      {:ok, url} ->
        {:ok, url}

      {:error, error} ->
        Logger.error("R2 upload URL error: #{inspect(error)}")
        {:error, error}
    end
  end

  @doc """
  Generate a unique key for file storage.
  """
  def generate_key(parent_id \\ nil, filename) do
    uuid = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
    folder_path = if parent_id, do: "#{parent_id}/", else: ""
    "#{folder_path}#{uuid}-#{filename}"
  end

  defp get_etag(result) do
    case result do
      %{headers: headers} ->
        Enum.find_value(headers, fn
          {"ETag", etag} -> etag
          _ -> nil
        end) || "unknown"

      _ ->
        "unknown"
    end
  end
end
