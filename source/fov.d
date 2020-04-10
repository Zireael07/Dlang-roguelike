module source.fov;
import source.map;

//Bjorn Bergstroem's recursive shadowcasting

//Multipliers for transforming coordinates to other octants
static int[8][4] multipliers = [
    [1, 0, 0, -1, -1, 0, 0, 1],
    [0, 1, -1, 0, 0, -1, 1, 0],
    [0, 1, 1, 0, 0, -1, -1, 0],
    [1, 0, 0, 1, -1, 0, 0, -1]
];


class ShadowCastFOV {
    int width,height;
    public int[] fovMap;
    public Map map;
  
    this(Map map)
    {
       this.width = map.width;
       this.height = map.height;
       this.map = map;
       this.fovMap = new int[width*height]; //defaults to 0, i.e. not seen
    }


    public void clearFOV()
    {
        //nice Dlang shortcut = assign to all elements
        this.fovMap[] = 0; // not seen
    }

    public void SetVisible(int x, int y)
    {
        //2d map to 1d array
        this.fovMap[x+y*this.width] = 1;
    }

    bool isVisible(int x, int y) 
    {
        return this.fovMap[x+y*this.width] == 1;
    }

    bool BlocksLight(int x, int y)
    {
        return this.map.isWall(x,y);
    }

    //helper (since we can't use std)
    int abs(int v)
    {
        if (v >= 0){
            return v;
        }
        else {
            return -v;
        }
    }

    //actual implementation
    //recursive shadowcasting function
    void cast_light(uint x, uint y, uint radius, uint row,
        float start_slope, float end_slope, uint xx, uint xy, uint yx, uint yy)
        {
        if (start_slope < end_slope) {
                return;
            }
        float next_start_slope = start_slope;
        for (uint i = row; i <= radius; i++) {
            bool blocked = false;
            for (int dx = -i, dy = -i; dx <= 0; dx++) {
                float l_slope = (dx - 0.5) / (dy + 0.5);
                float r_slope = (dx + 0.5) / (dy - 0.5);
                if (start_slope < r_slope) {
                    continue;
                } else if (end_slope > l_slope) {
                    break;
                }

                int sax = dx * xx + dy * xy;
                int say = dx * yx + dy * yy;

                if ((sax < 0 && cast(uint)(abs(sax)) > x) ||
                        (say < 0 && cast(uint)(abs(say)) > y)) {
                    continue;
                }
                uint ax = x + sax;
                uint ay = y + say;
                if (ax >= this.width || ay >= this.height) {
                    continue;
                }

                uint radius2 = radius * radius;
                if (cast(uint)(dx * dx + dy * dy) < radius2) {
                    SetVisible(ax, ay);
                }

                if (blocked) {
                    if (BlocksLight(ax, ay)) {
                        next_start_slope = r_slope;
                        continue;
                    } else {
                        blocked = false;
                        start_slope = next_start_slope;
                    }
                } else if (BlocksLight(ax, ay)) {
                    blocked = true;
                    next_start_slope = r_slope;
                    cast_light(x, y, radius, i + 1, start_slope, l_slope, xx,
                            xy, yx, yy);
                }
            }
            if (blocked) {
                break;
            }
        }
    }

    //compute
    void computeFOV(uint x, uint y, uint radius)
    {
        for (uint i = 0; i < 8; i++) {
            cast_light(x, y, radius, 1, 1.0, 0.0, multipliers[0][i],
                    multipliers[1][i], multipliers[2][i], multipliers[3][i]);
        }
    }

}