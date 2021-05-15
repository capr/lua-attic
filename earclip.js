
let xs = [140,220,140,250,180,100,10,120,150,150,110]
let ys = [110,110,70,70,210,160,10,30,20,60,40]

let x = i => xs[i]
let y = i => ys[i]

function t(x, y, i, j, k) {
	return x(i) * (y(j) - y(k)) + x(j) * (y(k) - y(i)) + x(k) * (y(i) - y(j))
}

int lv(x, y, points) {
	let index
	let miny = y(0)
	for (let i = 0; i < points; i++) {
		if (miny > y(i)) {
			miny = y(i)
			index = i
		}
	}
	return index
}

int ts(x, y, points, v) {
	let a = v - 1
	let b = v + 1
	if (a == -1)
		a = points - 1
	if (b == points)
		b = 0
	return t(x, y, a, v, b) > 0 ? 1 : -1
}

int tv(x, y, i, j, k) {
	let x1 = t(x, y, i, j, k)
	if (x1 > 0)
		return 1
	else if (x1 < 0)
		return -1
	else
		return 0
}

int is_convex(x, y, points, v) {
	return ts(x, y, points, v) * ts(x, y, points, lv(x, y, points)) > 0
}

int is_empty(x, y, points, v) {
	let a = v - 1
	let b = v + 1
	if (a == -1)
		a = points - 1
	if (b == points)
		b = 0
	let tsv = tv(x, y, v, a, b)
	for (let i = 0; i < points; i++) {
		if (i == v || i == a || i == b)
			continue
		if (tsv * tv(x, y, v, a, i) >= 0 && tsv * tv(x, y, a, b, i) >= 0 && tsv * tv(x, y, b, v, i) >= 0)
			return false
	}
	return true
}

function prune(v) {
	points--
	for(let i = v; i < points; i++) {

		x[i]=x[i+1]
		y[i]=y[i+1]
	}
}

void triangulate(get_x, get_y, points) {
	let diagonals = points - 3
	for (let n = 0; n < diagonals; n++) {
		for (let i = 0; i < points; i++) {
			if (is_convex(get_x, get_y, i) && is_empty(get_x, get_y, i)) {
				prune(i)
				break
			}
		}
	}
}
