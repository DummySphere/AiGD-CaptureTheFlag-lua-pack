
Vector2 = {}

function Vector2.add(_v1, _v2) -- _v1 + _v2
	return { _v1[1] + _v2[1], _v1[2] + _v2[2] }
end

function Vector2.sub(_v1, _v2) -- _v1 - _v2
	return { _v1[1] - _v2[1], _v1[2] - _v2[2] }
end

function Vector2.multiply(_v1, _n) -- _v1 * _n
	return { _v1[1] * _n, _v1[2] * _n }
end

function Vector2.divide(_v1, _n) -- _v1 * _n
	return { _v1[1] / _n, _v1[2] / _n }
end

function Vector2.dotProduct(_v1, _v2) -- _v1 . _v2
	return _v1[1] * _v2[1] + _v1[2] * _v2[2]
end

function Vector2.sqlength(_v) -- |_v|²
	return Vector2.dotProduct(_v, _v)
end

function Vector2.length(_v) -- |_v|
	return math.sqrt(Vector2.sqlength(_v))
end

function Vector2.normalize(_v) -- ||_v||
	local sqlength = Vector2.sqlength(_v)
	if sqlength > 0 then
		return Vector2.divide(_v, math.sqrt(sqlength))
	end
	error("can't normalize a null vector")
end

function Vector2.sqdistance(_v1, _v2) -- |_v2 - _v1|²
	return Vector2.sqlength(Vector2.sub(_v2, _v1))
end

function Vector2.distance(_v1, _v2) -- |_v2 - _v1|
	return Vector2.length(Vector2.sub(_v2, _v1))
end
