defmodule Pipelines.WriteToFileTest do
  use ExUnit.Case, async: false

  @binary "Some binary"
  @test_path "./write_to_filetests/write_to_file_folder"

  setup do
    File.rm(@test_path)

    on_exit(fn ->
      :meck.unload(IO)
      :meck.unload(File)
    end)
  end

  test "Writes a given item to a file with global config", _context do
    test_pid = self()

    :meck.expect(
      IO,
      :write,
      fn _, item ->
        send(test_pid, item)
        :ok
      end
    )

    :meck.expect(
      File,
      :open,
      fn _path, _opts ->
        {:ok, test_pid}
      end
    )

    pipelines = [
      {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "csv"}
    ]

    item = @binary

    state = %{spider_name: MySpider}

    # run the pipeline
    _result = Crawly.Utils.pipe(pipelines, item, state)

    assert_receive @binary
  end

  test "Writes a given item to a file with tuple config", _context do
    test_pid = self()

    :meck.expect(
      IO,
      :write,
      fn _, item ->
        send(test_pid, item)
        :ok
      end
    )

    :meck.expect(
      File,
      :open,
      fn _path, _opts ->
        {:ok, test_pid}
      end
    )

    pipelines = [
      {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "csv"}
    ]

    item = @binary

    state = %{spider_name: MySpider}

    # run the pipeline
    _result = Crawly.Utils.pipe(pipelines, item, state)

    assert_receive @binary
  end

  test "Create a folder if write folder does not exist", _context do
    test_pid = self()

    :meck.expect(
      IO,
      :write,
      fn _, item ->
        send(test_pid, item)
        :ok
      end
    )

    :meck.expect(
      File,
      :open,
      fn _path, _opts ->
        {:ok, test_pid}
      end
    )

    pipelines = [
      {Crawly.Pipelines.WriteToFile, folder: @test_path, extension: "csv"}
    ]

    item = @binary

    state = %{spider_name: MySpider}

    # run the pipeline
    _result = Crawly.Utils.pipe(pipelines, item, state)

    assert File.exists?(@test_path)
  end
end
