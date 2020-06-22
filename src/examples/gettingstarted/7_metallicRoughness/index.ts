import { convertToInterleavedGeometry } from "../../../lib/geometry/Geometry.Functions";
import { icosahedron } from "../../../lib/geometry/primitives/Polyhedrons";
import { fetchImage } from "../../../lib/io/loaders/Image";
import { ShaderMaterial } from "../../../lib/materials/ShaderMaterial";
import { Euler } from "../../../lib/math/Euler";
import { Matrix4 } from "../../../lib/math/Matrix4";
import {
  makeMatrix4Perspective,
  makeMatrix4RotationFromEuler,
  makeMatrix4Translation,
} from "../../../lib/math/Matrix4.Functions";
import { Vector3 } from "../../../lib/math/Vector3";
import { BufferGeometry } from "../../../lib/renderers/webgl2/buffers/BufferGeometry";
import { DepthTestFunc, DepthTestState } from "../../../lib/renderers/webgl2/DepthTestState";
import { Program } from "../../../lib/renderers/webgl2/programs/Program";
import { RenderingContext } from "../../../lib/renderers/webgl2/RenderingContext";
import { TexImage2D } from "../../../lib/renderers/webgl2/textures/TexImage2D";
import { CubeTexture } from "../../../lib/textures/CubeTexture";
import fragmentSourceCode from "./fragment.glsl";
import vertexSourceCode from "./vertex.glsl";

async function init(): Promise<null> {
  const geometry = convertToInterleavedGeometry(icosahedron(0.75, 3));
  const material = new ShaderMaterial(vertexSourceCode, fragmentSourceCode);
  const cubeTexture = new CubeTexture([
    await fetchImage("/assets/textures/cube/pisa/px.png"),
    await fetchImage("/assets/textures/cube/pisa/nx.png"),
    await fetchImage("/assets/textures/cube/pisa/py.png"),
    await fetchImage("/assets/textures/cube/pisa/ny.png"),
    await fetchImage("/assets/textures/cube/pisa/pz.png"),
    await fetchImage("/assets/textures/cube/pisa/nz.png"),
  ]);

  const context = new RenderingContext();
  const canvasFramebuffer = context.canvasFramebuffer;
  document.body.appendChild(canvasFramebuffer.canvas);

  const program = new Program(context, material);
  const uniforms = {
    localToWorld: new Matrix4(),
    worldToView: makeMatrix4Translation(new Matrix4(), new Vector3(0, 0, -1)),
    viewToScreen: makeMatrix4Perspective(new Matrix4(), -0.25, 0.25, 0.25, -0.25, 0.1, 4.0),
    roughnessFactor: 0,
    cubeMap: new TexImage2D(context, cubeTexture),
  };
  const bufferGeometry = new BufferGeometry(context, geometry);
  const depthTestState = new DepthTestState(true, DepthTestFunc.Less);

  function animate(): void {
    requestAnimationFrame(animate);

    const now = Date.now();
    uniforms.localToWorld = makeMatrix4RotationFromEuler(
      uniforms.localToWorld,
      new Euler(now * 0.0001, now * 0.00033, now * 0.000077),
    );
    uniforms.roughnessFactor = Math.sin(now * 0.0001) * 0.5 + 0.5;
    canvasFramebuffer.renderBufferGeometry(program, uniforms, bufferGeometry, depthTestState);
  }

  animate();

  return null;
}

init();