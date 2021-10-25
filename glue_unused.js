// dynamic array with stable element indices.
function stable_index_array(I) {
	I = I || 'i'
	let e = []
	let free = []
	e.add = function(e) {
		let i = free.pop()
		if (i == null)
			i = this.length
		this[i] = e
		e[I] = i
		return e
	}
	e.remove = function(e) {
		assert(e[I] != null)
		free.push(e[I])
		this[i] = undefined
		e[I] = null
		return e
	}
	e.clear = function() {
		for (let e of this)
			if (e)
				e[I] = null
		this.length = 0
		free.length = 0
	}
	return e
}
