function [eps_node_cell, mu_node_cell] = assign_material_node(grid3d, object_array, eps_node_cell, mu_node_cell)
% It takes an array with Nx x Ny x Nz elements and returns an array with (Nx+2)
% x (Ny+2) x (Nz+2) elements.

chkarg(istypesizeof(grid3d, 'Grid3d'), '"grid3d" should be instance of Grid.');
chkarg(istypesizeof(object_array, 'Object', [1 0]), ...
	'"object_array" should be row vector of instances of Object.');

if nargin < 3  % no eps_node_cell
	eps_node_cell = {NaN(grid3d.N), NaN(grid3d.N), NaN(grid3d.N)};
else
	eps_node_cell_temp = cell(1, Axis.count);
	for w = Axis.elems	
		eps_node_cell_temp{w} = eps_node_cell{w}(2:end-1,2:end-1,2:end-1);
	end
	eps_node_cell = eps_node_cell_temp;
end
chkarg(istypesizeof(eps_node_cell, 'complexcell', [1 Axis.count], grid3d.N), ...
	'"eps_node_cell" should be length-%d cell array whose each element is %d-by-%d-by-%d array with complex elements.', ...
	Axis.count, grid3d.N(Axis.x), grid3d.N(Axis.y), grid3d.N(Axis.z));

if nargin < 4  % no mu_node_cell
	mu_node_cell = {NaN(grid3d.N), NaN(grid3d.N), NaN(grid3d.N)};
else
	mu_node_cell_temp = cell(1, Axis.count);
	for w = Axis.elems	
		mu_node_cell_temp{w} = mu_node_cell{w}(2:end-1,2:end-1,2:end-1);
	end
	mu_node_cell = mu_node_cell_temp;	
end
chkarg(istypesizeof(mu_node_cell, 'complexcell', [1 Axis.count], grid3d.N), ...
	'"mu_node_cell" should be length-%d cell array whose each element is %d-by-%d-by-%d array with complex elements.', ...
	Axis.count, grid3d.N(Axis.x), grid3d.N(Axis.y), grid3d.N(Axis.z));

ldual = cell(1, Axis.count);  % locations of cell centers
for w = Axis.elems
	ldual{w} = grid3d.l{w, GT.dual};  % grid3d.l rather than grid3d.lg
end

ind = cell(1, Axis.count);  % indices
for obj = object_array
	shape = obj.shape;
	material = obj.material;
	for w = Axis.elems
		bn = shape.bound(w, Sign.n);
		bp = shape.bound(w, Sign.p);
		in = find(ldual{w} >= bn, 1, 'first');
		ip = find(ldual{w} <= bp, 1, 'last');
		ind{w} = in:ip;
	end

	if istypesizeof(shape, 'Box')
		for w = Axis.elems
			eps_node_cell{w}(ind{Axis.x}, ind{Axis.y}, ind{Axis.z}) = material.eps(w);
			mu_node_cell{w}(ind{Axis.x}, ind{Axis.y}, ind{Axis.z}) = material.mu(w);
		end
	else  % shape is not a Box
% 		for ix = ind{Axis.x}
% 			for iy = ind{Axis.y}
% 				for iz = ind{Axis.z}
% 					pt = [lprim{Axis.x}(ix), lprim{Axis.y}(iy), lprim{Axis.z}(iz)];
% 					if shape.contains(pt)
% 						eps_node(ix, iy, iz) = material.eps;
% 						mu_node(ix, iy, iz) = material.mu;
% 					end
% 				end
% 			end
% 		end
		[X, Y, Z] = ndgrid(ldual{Axis.x}(ind{Axis.x}), ldual{Axis.y}(ind{Axis.y}), ldual{Axis.z}(ind{Axis.z}));
		is_in = shape.contains([X(:), Y(:), Z(:)]);
		is_in = reshape(is_in, length(ind{Axis.x}), length(ind{Axis.y}), length(ind{Axis.z}));
		ind_tf = false(grid3d.N);  % logical indices
		ind_tf(ind{Axis.x}, ind{Axis.y}, ind{Axis.z}) = is_in;
		
		for w = Axis.elems
			eps_node_cell{w}(ind_tf) = material.eps(w);
			mu_node_cell{w}(ind_tf) = material.mu(w);
		end
	end
end
