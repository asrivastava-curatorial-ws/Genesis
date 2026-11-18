// plain_glb.mjs <in.glb> <out.glb> [pattern of node names to leave out]
// The same model without Draco compression (Godot reads plain glTF), and
// without the nodes whose names match the pattern (a maker's mark on a radio).
import { NodeIO } from '@gltf-transform/core';
import { ALL_EXTENSIONS } from '@gltf-transform/extensions';
import draco3d from 'draco3dgltf';

const [, , src, dst, pattern] = process.argv;
const io = new NodeIO().registerExtensions(ALL_EXTENSIONS).registerDependencies({ 'draco3d.decoder': await draco3d.createDecoderModule() });
const doc = await io.read(src);
for (const ext of doc.getRoot().listExtensionsUsed()) {
	if (ext.extensionName === 'KHR_draco_mesh_compression') ext.dispose();
}
let removed = 0;
if (pattern) {
	const re = new RegExp(pattern, 'i');
	for (const node of doc.getRoot().listNodes()) {
		if (re.test(node.getName())) {
			const mesh = node.getMesh();
			node.dispose();
			if (mesh && mesh.listParents().length <= 1) mesh.dispose();
			removed++;
		}
	}
}
await io.write(dst, doc);
const root = doc.getRoot();
console.log(`${src.split('/').pop()}: ${root.listMeshes().length} meshes, ${root.listMaterials().length} materials, ${root.listTextures().length} pictures` + (removed ? `, ${removed} nodes left out` : ''));
