%�¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢�
% Estimate the sparse signal x using pruned MMP
%
% y			: observation
% Phi		: Sensing matrix
% K			: Sparsity
% L			: The size of expanding tree
% cand_len	: The pruning size of candidate dictionareis
%
%	Output parameters
% x_mmp_s	: estimated signal
% x_supp	: selected support vector indice.
% idx_depth	: iteration count during estimating
%
% Written by Suhyuk Kwon
% Information System Lab., Korea Univ.
%�¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢�
function [x_mmp_s x_supp idx_depth] = islsp_EstMMP_BF_reuse(y, Phi, K, L, N_max)
	
	[nRows nCols]	= size(Phi);

	idx_depth		= 0;

	%% Define the hash function for performance issues.
	my_hash_f	= @sum;
	
	s_path_info				= struct(	'supps', zeros(K,1),...
										'residu', zeros(nRows, 1),...
										'x_hat', zeros(nCols, 1),...
										'prev_inv', zeros(1, 1),...
										'res_norm', zeros(1, 1),...
										'suppHash', int32(0));

	nodes_parents		= s_path_info(:,ones(L, 1));
	 
	%% Initialize the best path.
	[supp_mag supp_idx]	= sort(abs(Phi'*y), 'descend');
	for idx=1:L
		supps	= supp_idx(idx);
		
		x_hat	= pinv(Phi(:,supps))*y;
		residu	= y-x_hat.*Phi(:,supps);
		
		nodes_parents(idx).supps	= supps;
		nodes_parents(idx).residu	= residu;
		nodes_parents(idx).x_hat	= x_hat;
		nodes_parents(idx).prev_inv	= 1/(norm(Phi(:,supps))^2);
		nodes_parents(idx).res_norm	= norm(residu);
		nodes_parents(idx).suppHash	= my_hash_f(supps);
	end

	%% General iteration
	idx_abs_child	= L;
	
	while (idx_depth < K-1)
		idx_depth	= idx_depth+1;
		
		search_len	= min(idx_abs_child, N_max);

		%nodes_children(search_len*L)	= s_path_info;
		nodes_children		= s_path_info(:,ones(search_len*L, 1));
		
		idx_abs_child			= 0;
		for idx_best=1:search_len
			[supp_mag supp_idx]	= sort(abs(Phi'*nodes_parents(idx_best).residu), 'descend');

			% Generate the child nodes
			for idx_child=1:L
				% supps	= union(best_path_par(idx_best).supps, supp_idx(idx_child));
				
				% check existence among the previous selected indices
				if 0 ~= find( supp_idx(idx_child) == nodes_parents(idx_best).supps )
					continue;
				end
				
				supps			= [nodes_parents(idx_best).supps supp_idx(idx_child)];
				[x_hat MInv]	= islsp_EstX_reuse(	y,...
													Phi(:,nodes_parents(idx_best).supps),...
													Phi(:,supp_idx(idx_child)),...
													nodes_parents(idx_best).prev_inv);
				
				residu			= y-Phi(:,supps)*x_hat;

				%%
				% Check the duplication.
				same_hashes	= find( [nodes_children(:).suppHash] == my_hash_f(supps) );
				
				x_tmp_test	= sort(supps);
				
				dupl_test	= 0;
				
				for idx_hash=same_hashes
					x_tmp	= sort(nodes_children(idx_hash).supps);
					
					if 0 == sum(x_tmp-x_tmp_test)
						dupl_test	= 1;
						break;
					end
				end
				
				if dupl_test
					continue;
				end
				
				%%
				% Add new child node
				idx_abs_child	= idx_abs_child+1;
				
				nodes_children(idx_abs_child).supps		= supps;
				nodes_children(idx_abs_child).residu	= residu;
				nodes_children(idx_abs_child).x_hat		= x_hat;
				nodes_children(idx_abs_child).prev_inv	= MInv;
				nodes_children(idx_abs_child).res_norm	= norm(residu);
				nodes_children(idx_abs_child).suppHash	= my_hash_f(supps);
				
				
			end
		end
		
		if idx_abs_child < 1
			break;
		end
		
		nodes_parents	= nodes_children(1:idx_abs_child);
		
		[resi_val resi_idx] = sort([nodes_parents(:).res_norm]);

		x_mmp_s			= zeros(nCols, 1);
		x_supp			= nodes_parents(resi_idx(1)).supps;
		x_mmp_s(x_supp)	= nodes_parents(resi_idx(1)).x_hat;

		if N_max < idx_abs_child
			nodes_parents(resi_idx(N_max+1:end))	= [];
		end
	end
end

%%
function [x_hat reuse_inv] = islsp_EstX_reuse(y, prev_cols, new_col, reuse_Minv)

	reuse_b		= new_col'*prev_cols;
	xi			= reuse_b*reuse_Minv;
	reuse_p		= 1/(norm(new_col)^2 - reuse_b*xi');
	reuse_inv	= [(reuse_Minv+reuse_p*xi'*xi) (-reuse_p*xi');(-reuse_p*xi) reuse_p];

	x_hat		= reuse_inv*[(prev_cols'*y) ; (new_col'*y)];
end
