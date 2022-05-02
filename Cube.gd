class_name Cube
extends Reference

var FRONT_FACE = [Vector3(1, 1, 0), Vector3(0, 1, 0), Vector3(0, 0, 0),
				  Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 0, 0)]
var BACK_FACE =  [Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(1, 1, 1),
				  Vector3(0, 0, 1), Vector3(1, 1, 1), Vector3(1, 0, 1)]
var DOWN_FACE =  [Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 1),
				  Vector3(0, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, 0)]
var UP_FACE =    [Vector3(1, 1, 1), Vector3(0, 1, 1), Vector3(0, 1, 0),
				  Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 0)]
var LEFT_FACE =  [Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, 1),
				  Vector3(0, 0, 0), Vector3(0, 1, 1), Vector3(0, 0, 1)]
var RIGHT_FACE = [Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(1, 0, 0),
				  Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(1, 0, 0)]

var FRONT_NORMALS = [Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD,
					 Vector3.FORWARD, Vector3.FORWARD, Vector3.FORWARD]
var BACK_NORMALS =  [Vector3.BACK, Vector3.BACK, Vector3.BACK,
					 Vector3.BACK, Vector3.BACK, Vector3.BACK]
var DOWN_NORMALS =  [Vector3.DOWN, Vector3.DOWN, Vector3.DOWN,
					 Vector3.DOWN, Vector3.DOWN, Vector3.DOWN]
var UP_NORMALS =    [Vector3.UP, Vector3.UP, Vector3.UP,
					 Vector3.UP, Vector3.UP, Vector3.UP]
var LEFT_NORMALS =  [Vector3.LEFT, Vector3.LEFT, Vector3.LEFT,
					 Vector3.LEFT, Vector3.LEFT, Vector3.LEFT]
var RIGHT_NORMALS = [Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT,
					 Vector3.RIGHT, Vector3.RIGHT, Vector3.RIGHT]

var FRONT_UVS = [Vector2(0, 0.33), Vector2(0, 0.66), Vector2(0.25, 0.66),
				 Vector2(0.25, 0.33), Vector2(0, 0.33), Vector2(0.25, 0.66)]
var BACK_UVS = [Vector2(0.5, 0.66), Vector2(0.75, 0.66), Vector2(0.75, 0.33),
				Vector2(0.5, 0.66), Vector2(0.75, 0.33), Vector2(0.5, 0.33)]
var DOWN_UVS = [Vector2(0.25, 0.66), Vector2(0.5, 0.66), Vector2(0.5, 0.33),
				Vector2(0.25, 0.66), Vector2(0.5, 0.33), Vector2(0.25, 0.33)]
var UP_UVS = [Vector2(0.75, 0.33), Vector2(0.75, 0.66), Vector2(1, 0.66),
			  Vector2(1, 0.33), Vector2(0.75, 0.33), Vector2(1, 0.66)]
var LEFT_UVS = [Vector2(0.25, 0.66), Vector2(0.25, 1), Vector2(0.5, 1),
				Vector2(0.25, 0.66), Vector2(0.5, 1), Vector2(0.5, 0.66)]
var RIGHT_UVS = [Vector2(0.5, 0), Vector2(0.25, 0), Vector2(0.25, 0.33),
				 Vector2(0.5, 0.33), Vector2(0.5, 0), Vector2(0.25, 0.33)]
