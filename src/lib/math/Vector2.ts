//
// based on Vector2 from Three.js
//
// Authors:
// * @bhouston
//

import { IPrimitive } from './IPrimitive.js';

export class Vector2 implements IPrimitive<Vector2> {
	x: number;
	y: number;

	constructor(x: number = 0, y: number = 0) {
		this.x = x;
		this.y = y;
	}

	clone() {
		return new Vector2().copy(this);
	}

	copy(v: Vector2) {
		this.x = v.x;
		this.y = v.y;

		return this;
	}

	add(v: Vector2) {
		this.x += v.x;
		this.y += v.y;

		return this;
	}

	getComponent(index: number) {
		switch (index) {
			case 0:
				return this.x;
			case 1:
				return this.y;
			default:
				throw new Error('index of our range: ' + index);
		}
	}

	setComponent(index: number, value: number) {
		switch (index) {
			case 0:
				this.x = value;
				break;
			case 1:
				this.y = value;
				break;
			default:
				throw new Error('index of our range: ' + index);
		}

		return this;
	}

	numComponents() {
		return 3;
	}

	dot(v: Vector2) {
		return this.x * v.x + this.y * v.y;
	}

	length() {
		return Math.sqrt(this.x * this.x + this.y * this.y);
	}

	equals(v: Vector2) {
		return v.x === this.x && v.y === this.y;
	}
}
