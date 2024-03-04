local plugin = require("nvim-whisper")

describe("setup", function()
  it("works with default", function()
    assert(plugin.start() == "Hello!", "my first function with param = Hello!")
  end)

  it("works with custom var", function()
    plugin.setup({ opt = "custom" })
    assert(plugin.start() == "custom", "my first function with param = custom")
  end)
end)
