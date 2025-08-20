return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 5,
  height = 5,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 4,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "house",
      firstgid = 1,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 40,
      image = "../GFX/Inner.png",
      imagewidth = 640,
      imageheight = 400,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 1000,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 5,
      height = 5,
      id = 2,
      name = "Background",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        92, 92, 92, 92, 92,
        92, 92, 92, 92, 92,
        92, 92, 92, 92, 92,
        92, 92, 92, 92, 92,
        92, 92, 92, 92, 92
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 5,
      height = 5,
      id = 1,
      name = "Matto",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        281, 282, 282, 282, 283,
        321, 322, 322, 322, 323,
        321, 322, 322, 322, 323,
        321, 322, 322, 322, 323,
        361, 362, 362, 362, 363
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 5,
      height = 5,
      id = 3,
      name = "Jotain",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        57, 0, 0, 54, 56,
        97, 0, 0, 94, 96,
        137, 0, 0, 134, 136,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 564
      }
    }
  }
}
