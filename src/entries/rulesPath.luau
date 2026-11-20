local path = require("@std/path")

-- Repos run these rules by passing the rules folder to `lute lint --rules`.
-- `lute pkg install --vendor` puts the package in a folder named after its
-- version, so that path changes with every pin. Lute reports this file's own
-- path as its source, which leads to the rules folder beside it wherever the
-- package lives.
local sourcePath = path.resolve(debug.info(1, "s"))

-- The absolute path of the entry rules folder.
return path.format(path.join(path.dirname(sourcePath), "rules"))
