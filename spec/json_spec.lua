local json = require('rustaceanvim.config.json')
describe('Decode rust-analyzer settings from json', function()
  it('can extract rust-analyzer key from index', function()
    local json_content = [[
{
	"rust-analyzer.check.overrideCommand": [
		"cargo",
		"check",
		"-p",
		"service_b",
		"--message-format=json"
	],
	"rust-analyzer.foo.enable": true,
	"rust-analyzer.foo.bar.enable": true,
	"rust-analyzer.foo.bar.baz.bat": "something deeply nested",
	"some-other-key.foo.bar.baz.bat": "should not be included"
}
]]
    local tbl = {}
    local json_tbl = json.silent_decode(json_content)
    json.override_with_rust_analyzer_json_keys(tbl, json_tbl)
    assert.same({
      ['rust-analyzer'] = {
        check = {
          overrideCommand = {
            'cargo',
            'check',
            '-p',
            'service_b',
            '--message-format=json',
          },
        },
        foo = {
          enable = true,
          bar = {
            enable = true,
            baz = {
              bat = 'something deeply nested',
            },
          },
        },
      },
    }, tbl)
  end)
  it('persists warnings on invalid config', function()
    local invalid_json_content = [[
{
	"rust-analyzer.checkOnSave.overrideCommand": [
		"cargo",
		"check",
		"-p",
		"service_b",
		"--message-format=json"
	],
	"rust-analyzer.foo.enable": true,
	"rust-analyzer.foo.bar.enable": true,
	"rust-analyzer.foo.bar.baz.bat": "something deeply nested",
	"some-other-key.foo.bar.baz.bat": "should not be included"
}
]]
    local tbl = {
      ['rust-analyzer'] = {
        checkOnSave = true,
      },
    }
    local json_tbl = json.silent_decode(invalid_json_content)
    json.override_with_rust_analyzer_json_keys(tbl, json_tbl)
    assert.same({
      [[
Ignored field 'rust-analyzer.checkOnSave' of invalid type 'table': { "cargo", "check", "-p", "service_b", "--message-format=json" }
Please refer to the rust-analyzer documentation at
https://rust-analyzer.github.io/manual.html#rust-analyzer.checkOnSave
]],
    }, json.get_warnings())
  end)
  it('persists warnings about config parse errors', function()
    local unsupported_json_content = [[
{
  // This is a json5 comment
	"rust-analyzer.foo.enable": true,
}
]]
    json.silent_decode(unsupported_json_content)
    assert.same({
      'Failed to decode json: Expected object key string but found invalid token at character 5',
    }, json.get_errors())
  end)
end)
