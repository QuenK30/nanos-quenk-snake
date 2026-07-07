LANG = "en"                  -- language: "fr" or "en"

MAP_SIZE = 5000              -- half-extents for food spawn area

SNAKE_SPEED = 900            -- initial movement speed (units/sec)
SNAKE_BODY_SCALE = 0.7       -- scale factor for body segments
SNAKE_INITIAL_YAW = 90       -- initial head yaw rotation (degrees)

TRIGGER_HALF_SIZE = 50       -- head collision box half-extents
BODY_LIFESPAN = 30           -- seconds dead body segments linger on the map

FOOD_SPAWN_MIN_SEC = 3       -- minimum seconds between food spawns
FOOD_SPAWN_MAX_SEC = 7       -- maximum seconds between food spawns

CAM_HEIGHT = 4000            -- camera Z offset above snake
CAM_FORWARD_OFFSET = -900    -- camera X offset (negative = behind snake)
CAM_PITCH = -90              -- camera pitch angle (negative = look down)
