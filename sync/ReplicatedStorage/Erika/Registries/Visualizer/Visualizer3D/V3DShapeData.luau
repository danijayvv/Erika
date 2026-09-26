-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

const V3DTypes = require('./V3DTypes')

const clamp = math.clamp
const cos = math.cos
const floor = math.floor
const min = math.min
const pi = math.pi
const rad = math.rad
const sin = math.sin

const ShapeCallbacks = table.freeze( {
	Line = function( self: V3DTypes.Visualizer3DType , T: number ): Vector3
		return self.Pivot + Vector3.new( ( T - 0.5 ) * self.LineSpacing * ( self.BarCount - 1 ) , 0 , 0 )
	end,
	Arc = function( self: V3DTypes.Visualizer3DType , T: number ): Vector3
		local Angle = rad( self.StartAngle ) + T * rad( self.ArcAngle )
		return self.Pivot + Vector3.new( cos( Angle ) * self.Radius , 0 , sin( Angle ) * self.Radius )
	end,
	Polygon = function( self: V3DTypes.Visualizer3DType , T: number ): Vector3
		local Sides = self.PolygonSides
		local AngleStep = ( pi * 2 ) / Sides
		local Scaled = T * Sides
		local Index = min( floor( Scaled ) , Sides - 1 )
		local function VertexAt( i: number )
			local Angle = i * AngleStep + rad( self.StartAngle )
			return Vector3.new( cos( Angle ) * self.Radius, 0, sin( Angle ) * self.Radius )
		end
		return self.Pivot + VertexAt( Index ):Lerp( VertexAt( ( Index + 1 ) % Sides ) , Scaled - Index )
	end,
	Star = function( self: V3DTypes.Visualizer3DType , T: number ): Vector3
		local VertexCount = self.StarPoints * 2
		local AngleStep = pi / self.StarPoints
		local function VertexAt( i: number ): Vector3
			local Angle = i * AngleStep + rad( self.StartAngle )
			local Radius = if i % 2 == 0 then self.StarOuterRadius else self.StarInnerRadius
			return Vector3.new( cos( Angle ) * Radius , 0 , sin( Angle ) * Radius )
		end
		local Scaled = clamp( T , 0 , 1 ) * VertexCount
		local Index = min( floor( Scaled ), VertexCount - 1)
		return self.Pivot + VertexAt( Index ):Lerp(  VertexAt( ( Index + 1 ) % VertexCount ) , Scaled - Index )
	end,
	Wave = function( self: V3DTypes.Visualizer3DType , T: number ): Vector3
		return self.Pivot + Vector3.new( ( T - 0.5 ) * self.LineSpacing * ( self.BarCount - 1 ) , 0 , sin( T * pi * 2 * self.WaveFrequency ) * self.WaveAmplitude )
	end,
	Heart = function(self: V3DTypes.Visualizer3DType, T: number): Vector3
		local Angle = T * pi * 2 + rad( self.StartAngle )
		local Scale = self.Radius / 16
		return self.Pivot + Vector3.new( ( 16 * sin( Angle ) ^ 3 ) * Scale , 0 , -( 13 * cos( Angle ) - 5 * cos( 2 * Angle ) - 2 * cos( 3 * Angle ) - cos( 4 * Angle ) ) * Scale )
	end,
	Infinity = function( self: V3DTypes.Visualizer3DType , T: number ): Vector3
		local Angle = T * pi * 2 + rad( self.StartAngle )
		local Scale = self.Radius / ( 1 + sin( Angle ) ^ 2 )
		return self.Pivot + Vector3.new( Scale * cos( Angle ) , 0 , Scale * sin( Angle ) * cos( Angle ) )
	end,
} ) :: { [V3DTypes.ShapeType]: ( self: V3DTypes.Visualizer3DType , T: number ) -> Vector3 }

return table.freeze( {
	ShapeCallbacks = ShapeCallbacks,
	ClosedShapes = table.freeze{
		Arc = true,
		Polygon = true,
		Star = true,
		Heart = true,
		Infinity = true,
	} :: { [V3DTypes.ShapeType]: boolean },
} )