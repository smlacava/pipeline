function statistics = classification(data, split_value, n_trees, ...
    bagging_value, random_subspace_value, pruning_depth, ...
    n_repetitions, min_samples)
    
    switch nargin
        case 1
            split_value = 0.8;
            n_trees = 1;
            bagging_value = [];
            random_subspace_value = [];
            pruning_depth = [];
            n_repetitions = 1;
            min_samples = 1;
        case 2
            n_trees = 1;
            bagging_value = [];
            random_subspace_value = [];
            pruning_depth = [];
            n_repetitions = 1;
            min_samples = 1;
        case 3
            bagging_value = [];
            random_subspace_value = [];
            pruning_depth = [];
            n_repetitions = 1;
            min_samples = 1;
        case 4
            random_subspace_value = [];
            pruning_depth = [];
            n_repetitions = 1;
            min_samples = 1;
        case 5
            pruning_depth = [];
            n_repetitions = 1;
            min_samples = 1;
        case 6
            n_repetitions = 1;
            min_samples = 1;
        case 7
            min_samples = 1;
    end
    
    f = waitbar(0,'Processing your data', 'Color', '[0.67 0.98 0.92]');
    fchild = allchild(f);
    fchild(1).JavaPeer.setForeground(fchild(1).JavaPeer.getBackground.BLUE)
    fchild(1).JavaPeer.setStringPainted(true)
    
    statistics = struct();
    if not(istable(data)) && (ischar(data) || isstring(data))
        try
            load(strcat(path_check(strcat(path_check(data), ...
                'Classification')), 'Classification_Data.mat'))
        catch
            problem('Data is not in the right format (table or file path)')
            return;
        end
    end
    if not(istable(data))
        problem('Data is not usable by classification process')
        return;
    end
    
    bg_color = [0.67 0.98 0.92];

    accuracy = 0;
    max_accuracy = 0;
    min_accuracy = 1;
    false_PAT = 0;
    false_HC = 0;
    true_PAT = 0;
    true_HC = 0;
     
    if min(size(data)) == 1
        problem('There are not enough parameters to evaluate')
        return;
    end
    
    
    if split_value > 1
        split_value = split_value/n_cases;
    end
    for r = 1:n_repetitions
        cvpt = cvpartition(data.group, "Holdout", 1-split_value);
        data_test = data(test(cvpt),:);
        data_train = data(training(cvpt),:);
        n_train = length(data_train.group);
        group_check = sum(data_train.group == 0);
        while group_check == n_train || group_check < min_samples
            cvpt = cvpartition(data.group, "Holdout", 1-split_value);
            data_train = data(training(cvpt),:);
            data_test = data(test(cvpt),:);
            group_check = sum(data_train.group == 0);
        end
    
        results = cell(n_trees, 1);
        for i = 1:n_trees
            data_train = random_subspace(data_train, random_subspace_value);
            data_train = bagging(data_train, bagging_value);
            tree = decision_tree(data_train, bagging_value, ...
                random_subspace_value, pruning_depth);
            results{i, 1} = predict(tree, data_test);
        end
        
        predictions = [];
        for i = 1:length(results)
            predictions = [predictions, results{i}];
        end
        predictions = round(mean(predictions, 2));
        
        n_test = length(predictions);
        n_HC = sum(data_test.group == 0);
        n_PAT = sum(data_test.group == 1);
        aux_FPAT =  sum(predictions > data_test.group)/n_HC;
        aux_TPAT = sum((predictions == data_test.group) & ...
            (predictions == 1))/n_PAT;
        aux_FHC = sum(predictions < data_test.group)/n_PAT;
        aux_THC = sum((predictions == data_test.group) & ...
            (predictions == 0))/n_HC;
        
        aux_accuracy = sum(data_test.group == predictions)/n_test;
        false_PAT = false_PAT + aux_FPAT;
        false_HC = false_HC + aux_FHC;
        true_HC = true_HC + aux_THC;
        true_PAT = true_PAT + aux_TPAT;
        accuracy = accuracy + aux_accuracy;
        if aux_accuracy > max_accuracy
            max_accuracy = aux_accuracy;
        end
        if aux_accuracy < min_accuracy
            min_accuracy = aux_accuracy;
        end
        waitbar(r/n_repetitions, f)
    end
    
    waitbar(1, f ,'Exporting data')    
    accuracy = accuracy/n_repetitions;
    true_PAT = true_PAT/n_repetitions;
    false_PAT = false_PAT/n_repetitions;
    true_HC = true_HC/n_repetitions;
    false_HC = false_HC/n_repetitions;    
    
    statistics.parameters = struct();
    statistics.parameters.split_value = split_value;
    statistics.parameters.trees_number = n_trees;
    statistics.parameters.bagging_value = bagging_value;
    statistics.parameters.random_subspace = random_subspace_value;
    statistics.parameters.pruning_depth = pruning_depth;
    statistics.parameters.repetitions = n_repetitions;
    statistics.parameters.min_samples = min_samples;
    statistics.accuracy = accuracy;
    statistics.min_accuracy = min_accuracy;
    statistics.max_accuracy = max_accuracy;
    statistics.confusion_matrix = struct();
    statistics.confusion_matrix.matrix = [true_PAT, false_HC; ...
        false_PAT, true_HC];
    statistics.confusion_matrix.rows = {'PAT', 'HC'};
    statistics.confusion_matrix.columns = ...
        {'PAT_predicted', 'HC_predicted'};
    
    cm = [true_PAT, false_HC; false_PAT, true_HC];
    confusion_matrix(cm, accuracy, bg_color);
    close(f)
end