--- 3D model previewer for yazi, backed by f3d.
--- Renders STL / 3MF / STEP / OBJ / glTF / FBX / USD / … to a PNG in yazi's
--- preview cache, then shows it with the terminal's image protocol.

local M = {}

-- ext -> { plugin = <f3d plugin needed>, up = <up axis> }
-- `plugin = nil` means the format is handled by f3d's built-in `native` reader.
local FORMATS = {
	-- native, Z-up (CAD / 3D printing)
	stl = { up = "+Z" },
	ply = { up = "+Z" },
	vtk = { up = "+Z" },
	vtp = { up = "+Z" },
	vtu = { up = "+Z" },
	vtr = { up = "+Z" },
	vti = { up = "+Z" },
	vts = { up = "+Z" },
	vtm = { up = "+Z" },
	pts = { up = "+Z" },
	gml = { up = "+Z" },
	dcm = { up = "+Z" },
	splat = { up = "+Z" },
	spz = { up = "+Z" },
	-- native, Y-up (scene / DCC formats)
	obj = { up = "+Y" },
	gltf = { up = "+Y" },
	glb = { up = "+Y" },
	["3ds"] = { up = "+Y" },
	mdl = { up = "+Y" },
	-- assimp plugin
	["3mf"] = { plugin = "assimp", up = "+Z" },
	off = { plugin = "assimp", up = "+Z" },
	dxf = { plugin = "assimp", up = "+Z" },
	fbx = { plugin = "assimp", up = "+Y" },
	dae = { plugin = "assimp", up = "+Y" },
	x = { plugin = "assimp", up = "+Y" },
	-- occt plugin (CAD)
	step = { plugin = "occt", up = "+Z" },
	stp = { plugin = "occt", up = "+Z" },
	stpnc = { plugin = "occt", up = "+Z" },
	p21 = { plugin = "occt", up = "+Z" },
	brep = { plugin = "occt", up = "+Z" },
	xbf = { plugin = "occt", up = "+Z" },
	-- other plugins
	abc = { plugin = "alembic", up = "+Y" },
	usd = { plugin = "usd", up = "+Y" },
	usda = { plugin = "usd", up = "+Y" },
	usdc = { plugin = "usd", up = "+Y" },
	usdz = { plugin = "usd", up = "+Y" },
	vdb = { plugin = "vdb", up = "+Z" },
	vtkhdf = { plugin = "hdf", up = "+Z" },
}

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then
		return
	end

	local ok, err = self:preload(job)
	if not ok or err then
		return ya.preview_widget(job, err)
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek() end

-- yazi 26.9.x expone `fs.cha`; versiones mas nuevas lo renombraron a `fs.stat`.
local fs_stat = fs.cha or fs.stat

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs_stat(cache) then
		return true
	end

	local fmt = FORMATS[(job.file.url.ext or ""):lower()]
	if not fmt then
		return false, Err("Unsupported 3D format")
	end

	-- Sin forzar backend ni GPU: f3d elige solo y usa la GPU del compositor.
	-- Forzar EGL caia en la iGPU (EGL device 0) y el indice cambia entre boots.
	local output, err = M.render(job, cache, fmt)

	if err then
		return true, Err("Failed to start `f3d`, error: %s", err)
	elseif not output.status.success then
		return false, Err("`f3d` exited with error code %s: %s", output.status.code, output.stderr)
	else
		return true
	end
end

function M.render(job, cache, fmt)
	local args = job.args or {}

	local cmd = Command("f3d"):arg {
		"--no-config",
		"--verbose=quiet",
		"--input=" .. tostring(job.file.path),
		"--output=" .. tostring(cache),
		string.format("--resolution=%d,%d", rt.preview.max_width, rt.preview.max_height),
		"--up=" .. (args.up or fmt.up),
		"--camera-direction=" .. (args.view or "-1,-1,-1"),
		"--anti-aliasing=fxaa",
		"--ambient-occlusion",
		"--tone-mapping",
		"--light-intensity=" .. (args.light or 2.5),
	}

	if fmt.plugin then
		cmd:arg("--load-plugins=" .. fmt.plugin)
	end
	if args.bg then
		cmd:arg("--background-color=" .. args.bg)
	else
		cmd:arg("--no-background")
	end
	if args.color ~= false then
		cmd:arg { "--color=" .. (args.color or "#c9d1d9"), "--metallic=0", "--roughness=0.55" }
	end
	if args.edges then
		cmd:arg("--edges")
	end
	if args.grid then
		cmd:arg("--grid")
	end
	if args.axis then
		cmd:arg("--axis")
	end
	if args.max_size then
		cmd:arg("--max-size=" .. args.max_size)
	end

	return cmd:stdout(Command.PIPED):stderr(Command.PIPED):output()
end

return M
