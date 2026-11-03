## Shape colors: hue is always fully saturated, lightness comes from where the shape's
## mass sits among all shapes (lightest = light tint, heaviest = dark shade).
## Both ends stay away from white/black so the hue still reads.
class_name ShapePalette

const LIGHTEST := 0.82
const DARKEST := 0.28


static func make_color(hue: float, mass_percentile: float) -> Color:
	var lightness := lerpf(LIGHTEST, DARKEST, clampf(mass_percentile, 0.0, 1.0))
	return Color.from_ok_hsl(clampf(hue, 0.0, 1.0), 1.0, lightness)


## recomputes every shape's mass percentile (0 = lightest, 1 = heaviest, ties share a value)
static func refresh(tree: SceneTree) -> void:
	var shapes: Array[Shape] = []
	for node in tree.get_nodes_in_group("shapes"):
		if node is Shape and not node.is_queued_for_deletion():
			shapes.append(node)
	var n := shapes.size()
	for s in shapes:
		var less := 0
		var equal := 0
		for other in shapes:
			if other.mass < s.mass - 0.0001:
				less += 1
			elif absf(other.mass - s.mass) <= 0.0001:
				equal += 1
		var p := 0.5
		if n > 1:
			p = (float(less) + float(equal - 1) * 0.5) / float(n - 1)
		s.set_mass_percentile(p)
