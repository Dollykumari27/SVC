function [x_mmp_s x_supp idx_depth] = algo_mmp(y, Phi, K, L, N)
	
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
	 


	%% General iteration
	idx_abs_child	= L;
	
	
				
				
			end
		end
		
		if idx_abs_child < 1
			break;
		end
		
		nodes_parents	= nodes_children(1:idx_abs_child);
		
		[resi_val resi_idx] = sort([nodes_parents(:).res_norm]);

		if N_max < idx_abs_child
			nodes_parents(resi_idx(N_max:end))	= [];
		end
	end
end
end
