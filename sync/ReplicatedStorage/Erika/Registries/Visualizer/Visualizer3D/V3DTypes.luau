-- © 2026 iM1GHTB3DANI/danijayvv
--!strict

const V3DDefaultInfo = require('./V3DDefaultInfo')
const VisualizerBase = require('../VisualizerBase')

export type ShapeType = 'Line' | 'Arc' | 'Polygon' | 'Star' | 'Wave' | 'Heart' | 'Infinity'
export type Info3D = VisualizerBase.InfoBase & {
	BarThickness: number?,
	BarDepth: number?,
	LineSpacing: number?,
	Pivot: Vector3?,
	Shape: ShapeType?,
	StartAngle: number?,
	Radius: number?,
	
	StarPoints: number?,
	StarInnerRadius: number?,
	StarOuterRadius: number?,
	PolygonSides: number?,
	WaveFrequency: number?,
	WaveAmplitude: number?,
	ArcAngle: number?,
}
export type Visualizer3DType = Info3D & {
	VisualizerContainer: Model,
	Bars: { [number]: BasePart },
} & typeof( V3DDefaultInfo )

return {}