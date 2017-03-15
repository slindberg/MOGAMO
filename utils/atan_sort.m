function X_sorted = atan_sort(X_unsorted)
%ATAN_SORT Sort points by their position along the unit arc
    X_sorted = [ X_unsorted atan(X_unsorted(:,2)./X_unsorted(:,1)) ];
    X_sorted = sortrows(X_sorted, 3);
    X_sorted(:,3) = [];
end

