class_name BallPredictor
## Pure-math helper that projects the ball's path forward, bouncing off
## top/bottom walls, and optionally draws the result as a debug overlay.


## Predicts the Y coordinate where the ball will reach target_x.
## Set include_bounces to false to return NAN when a wall would be hit first.
static func predict_y(
	ball_pos: Vector2,
	ball_dir: Vector2,
	target_x: float,
	ball_radius: float,
	viewport_size: Vector2,
	include_bounces: bool = true,
) -> float:
	var path := simulate_path(
		ball_pos,
		ball_dir,
		target_x,
		ball_radius,
		viewport_size,
		10 if include_bounces else 0,
	)
	if path.size() < 2:
		return NAN
	return path[-1].y


## Simulates the ball's path toward target_x, reflecting off top/bottom walls
## up to max_bounces times. Returns the list of global-space points.
static func simulate_path(
	ball_pos: Vector2,
	ball_dir: Vector2,
	target_x: float,
	ball_radius: float,
	viewport_size: Vector2,
	max_bounces: int = 10,
) -> Array[Vector2]:
	var points: Array[Vector2] = [ball_pos]

	if ball_dir == Vector2.ZERO or ball_dir.x == 0:
		return points

	# Ball must be heading toward target_x
	if (target_x > ball_pos.x and ball_dir.x < 0) or (target_x < ball_pos.x and ball_dir.x > 0):
		return points

	var sim_pos := ball_pos
	var sim_dir := ball_dir

	# The ball bounces before reaching the actual wall edge
	var wall_top := ball_radius
	var wall_bottom := viewport_size.y - ball_radius

	for i in range(max_bounces + 1):
		var t := (target_x - sim_pos.x) / sim_dir.x
		if t < 0:
			break

		var predicted_y := sim_pos.y + sim_dir.y * t

		if predicted_y < wall_top and sim_dir.y != 0:
			var t_wall := (wall_top - sim_pos.y) / sim_dir.y
			sim_pos = sim_pos + sim_dir * t_wall
			points.append(sim_pos)
			sim_dir.y = -sim_dir.y
		elif predicted_y > wall_bottom and sim_dir.y != 0:
			var t_wall := (wall_bottom - sim_pos.y) / sim_dir.y
			sim_pos = sim_pos + sim_dir * t_wall
			points.append(sim_pos)
			sim_dir.y = -sim_dir.y
		else:
			points.append(Vector2(target_x, predicted_y))
			break

	return points


## Draws the predicted path as yellow segments with a red endpoint.
## Call from the ball's _draw() — coordinates must be converted to local space.
static func draw_prediction(ball: Node2D, points: Array[Vector2]) -> void:
	for i in range(points.size() - 1):
		(
			ball
			. draw_line(
				ball.to_local(points[i]),
				ball.to_local(points[i + 1]),
				Color.YELLOW,
				1.5,
			)
		)
	if points.size() > 1:
		ball.draw_circle(ball.to_local(points[-1]), 6.0, Color.RED)
