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
end)
