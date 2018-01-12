clear

% Initialize
addpath('auxiliary_functions/');
name_dataset = 'Gowalla';
% name_dataset = 'Brightkite';
rng('Shuffle');
rng_params=rng;


% Set parameters (uncomment depending on the desired experiment: Laplacian, Normal (Gaussian) or Circular noise.
nSamples=5000;
QmaxWC=1.5; % Worst-case loss in km
experiment_set = {'LapT',2./[0.05 0.1 0.3 0.5 0.75 1 1.25 1.5 1.75 2]; % Parameter set of the Laplacian noise. The parameter is epsilon.
    'NorT',sqrt(2/pi)*[0.05 0.1 0.3 0.5 0.75 1 1.25 1.5 1.75 2]; % The parameter in this case is "B"
    'CirT',3/2*[0.05 0.1 0.3 0.5 0.75 1 1.25 1.5 1.75 2]}; % This parameter in this case is the radius.

for i_exp = 1:size(experiment_set,1)
    method = experiment_set{i_exp,1};
    param_list = experiment_set{i_exp,2};
    
    % Load dataset
    load(sprintf('DATA_SF_%s_parsed.mat',name_dataset),'X','priorX','user_location_pairs');
    
    % Initialize variables with results
    QnoR_measures=zeros(nSamples,length(param_list)); % Average loss without remapping
    QminL2_measures=zeros(nSamples,length(param_list)); % Average loss, Euclidean with remapping
    PAEl2_measures=zeros(nSamples,length(param_list)); % Average adversary error, Euclidean
    PAEH_measures=zeros(nSamples,length(param_list)); % Average adversary error, Hamming
    PAEMSE_measures=zeros(nSamples,length(param_list)); % Average adversary error, MSE
    PCE_measures=zeros(nSamples,length(param_list)); % Conditional entropy
    
    
    time_iters=zeros(length(param_list),1);
    tic;
    for i_param=1:length(param_list)
        
        initial_time_iter=tic;
        param = param_list(i_param);
        
        % Get [nSamples] samples from the input locations of the users (we can't take them all)
        samples_idx_users=randsample(1:size(user_location_pairs,1),nSamples,'true'); % all the samples from the users
        
        for k=1:nSamples % for each sample...
            
            x_val_idx = user_location_pairs(samples_idx_users(k),2); % The index of the input location
            x_val = X(x_val_idx,:); % The input location, in Cartesian coordinates
            
            % Add noise and measure loss without remapping
            noise = compute_noise( method, struct('param',param,'QmaxWC',QmaxWC) );
            z_val = x_val + noise;
            QnoR_measures(k,i_param) = norm(noise);
            
            % Compute the posterior
            posteriorX = compute_posterior( method, struct('priorX',priorX,'param',param,'X',X,'z_val',z_val,'QmaxWC',QmaxWC) );
            
            % Compute the optimal remapping using the WC loss constraint
            % 1) Compute the mean and see if it's valid
            z_val_mean = posteriorX'*X;
            if any(get_distance_matrix('lp2',X(posteriorX>0,:),z_val_mean)>QmaxWC)
                % 2) If there are a lot of points we ignore this output, if not, we try to remap it with the geometric median.
                if sum(posteriorX>0)<1000
                    aux_output = compute_geometric_median_QmaxWC( posteriorX(posteriorX>0), X(posteriorX>0,:), QmaxWC );
                    if get_distance_matrix('lp2',X(posteriorX>0,:),z_val)*posteriorX(posteriorX>0,:)>get_distance_matrix('lp2',X(posteriorX>0,:),aux_output)*posteriorX(posteriorX>0,:)
                        % If the geometric median with constraints worked (does better than what we had), we use it
                        z_val_remapped = aux_output;
                    else
                        z_val_remapped = z_val;
                    end
                else
                    z_val_remapped = z_val;
                end
            else
                z_val_remapped = z_val_mean;
            end
            % Average loss, Euclidean
            QminL2_measures(k,i_param) = norm(x_val-z_val_remapped);
            
            % Average error, Euclidean
            z_est = compute_geometric_median( posteriorX, X);
            PAEl2_measures(k,i_param) = norm(x_val-z_est);
            
            % Average error, MSE
            z_val_mean = posteriorX'*X; % Mean remapping (not geometric median)
            PAEMSE_measures(k,i_param) = norm(x_val-z_val_mean);
            
            % Average error, Hamming
            [~,largest_posteriorX_idx] = max(posteriorX);
            PAEH_measures(k,i_param) = largest_posteriorX_idx~=x_val_idx;
            
            % Conditional Entropy
            PCE_measures(k,i_param) = sum(-posteriorX(posteriorX>0).*log2(posteriorX(posteriorX>0)));
            
            
            if mod(k,floor(nSamples/10))==0
                fprintf('%s: Param=%1.2f, done %4.0f/%d reps  | avgQL=%1.3f, avgQnoR=%1.3f, PAE=%1.3f, PAEH=%1.3f, PCE=%1.3f (%1.0f secs).\n',...
                    method,param_list(i_param),k,nSamples,mean(QminL2_measures(1:k,i_param)),mean(QnoR_measures(1:k,i_param)),mean(PAEl2_measures(1:k,i_param)),...
                    mean(PAEH_measures(1:k,i_param)),mean(PCE_measures(1:k,i_param)),toc);
                
            end
            
            
        end
        
        time_iters(i_param)=toc(initial_time_iter);
        
    end
    
    save(sprintf('RESULTS/RES_SFQWC_%s_%s.mat',method,name_dataset),'QminL2_measures','QnoR_measures',...
        'PAEl2_measures','PAEMSE_measures','PAEH_measures','PCE_measures',...
        'param_list','rng_params','nSamples','time_iters');
    fprintf('Saved RESULTS/RES_SFQWC_%s_%s.mat\n',method,name_dataset);
    
end


