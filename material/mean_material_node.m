function material_cell = mean_material_node(gt, material_node)
chkarg(istypesizeof(gt, 'GT'), '"gt" should be instance of GT.');
chkarg(istypesizeof(material_node, 'complexcell', [1 Axis.count], zeros(1, Axis.count)), ...
	'"material_node" should be length-%d cell array whose each element is %dD array with complex elements.', Axis.count, Axis.count);

if gt == GT.prim
	% material parameters for fields on primary grid
	material_cell = arithmetic_mean_material_node(material_node);
else  % gt == GT.dual
	% material parameters for fields on dual grid
	material_cell = harmonic_mean_material_node(material_node);
end


function material_edge_cell = arithmetic_mean_material_node(material_node)
material_edge_cell = cell(1, Axis.count);

material_edge_cell{Axis.x} = (...
	material_node{Axis.x}(2:end-1, 2:end-1, 2:end-1) ...
	+ material_node{Axis.x}(2:end-1, 1:end-2, 2:end-1) ...
	+ material_node{Axis.x}(2:end-1, 2:end-1, 1:end-2) ...
	+ material_node{Axis.x}(2:end-1, 1:end-2, 1:end-2)...
) / 4;

material_edge_cell{Axis.y} = (...
	material_node{Axis.y}(2:end-1, 2:end-1, 2:end-1) ...
	+ material_node{Axis.y}(2:end-1, 2:end-1, 1:end-2) ...
	+ material_node{Axis.y}(1:end-2, 2:end-1, 2:end-1) ...
	+ material_node{Axis.y}(1:end-2, 2:end-1, 1:end-2)...
) / 4;

material_edge_cell{Axis.z} = (...
	material_node{Axis.z}(2:end-1, 2:end-1, 2:end-1) ...
	+ material_node{Axis.z}(1:end-2, 2:end-1, 2:end-1) ...
	+ material_node{Axis.z}(2:end-1, 1:end-2, 2:end-1) ...
	+ material_node{Axis.z}(1:end-2, 1:end-2, 2:end-1)...
) / 4;


function material_face_cell = harmonic_mean_material_node(material_node)
material_face_cell = cell(1, Axis.count);
material_face_cell{Axis.x} = 2./(1./material_node{Axis.x}(1:end-2, 2:end-1, 2:end-1) + 1./material_node{Axis.x}(2:end-1, 2:end-1, 2:end-1));
material_face_cell{Axis.y} = 2./(1./material_node{Axis.y}(2:end-1, 1:end-2, 2:end-1) + 1./material_node{Axis.y}(2:end-1, 2:end-1, 2:end-1));
material_face_cell{Axis.z} = 2./(1./material_node{Axis.z}(2:end-1, 2:end-1, 1:end-2) + 1./material_node{Axis.z}(2:end-1, 2:end-1, 2:end-1));
