function polys = getPolygonBoxes(boxes, labels, mapper)
% This function generates polygon shape bounding boxes from quadrilateral
% boxes.

% Copyright 2021 The Mathworks, Inc.

% configurations
numCp = 5;
maxLenRatio = 0.7;
expandRatio = 1.45;
rMax = 2.0;
rStep = 0.2;

polys = [];
for i = 1:size(boxes,1)
    box = reshape(boxes(i,:,:),[2 4]);
    box = box';
    % size filter for small instance
    w = int32(norm(box(1,:)-box(2,:))+1);
    h = int32(norm(box(2,:)-box(3,:))+1);
    if w < 10 || h < 10
        polys = [polys; NaN([1 28])];
        continue;
    end

    % warp image
    tar = double([[1,1];[w,1];[w,h];[1,h]]);
    M = fitgeotrans(box,tar,'projective');
    wordLabel = imwarp(labels,M,'nearest','OutputView',imref2d([h w]));
    try
        Minv = inv(transpose(M.T));
    catch
        polys = [polys; NaN([1 28])];
        continue;
    end
    
    % binarization for selected label
    cur_label = mapper(i);
    wordLabel(wordLabel ~= cur_label) = 0;
    wordLabel(wordLabel > 0) = 1;

    % Polygon generation

    % find top/bottom contours
    cp = []; % stores the top and bottom location of the column in word label containing word
    maxLen = -1;
    for j = 1:w
        region = find(wordLabel(:,j)~=0);
        if size(region,1) < 2
            continue
        end
        cp = [cp; [j,region(1),region(end)]];
        lengths = region(end) - region(1) + 1;
        if lengths > maxLen
            maxLen = lengths;
        end
    end
    
    % pass if maxLen is similar to h
    if h * maxLenRatio <  maxLen
        polys = [polys; NaN([1 28])];
        continue;
    end

    % get pivot points with fixed length
    totSeg = numCp * 2 + 1;
    segW = double(w)/totSeg; % segment_width
    pp = repmat([nan,nan],numCp,1); % init pivot points
    cpSection = repmat([0,0],totSeg,1); % stores center point of each section
    segHeight = zeros([1 numCp]);
    segNum = 1;
    numSec = 0;
    prevH = -1;
    for k = 1:length(cp)
        x = cp(k,1); 
        sy = cp(k,2);
        ey = cp(k,3);
        if (segNum) * segW <= (x-1) && segNum <= totSeg
            % average previous segment
            if numSec == 0
                break;
            end
            cpSection(segNum,:) = [cpSection(segNum,1)/numSec cpSection(segNum,2)/numSec];
            numSec = 0;
            % reset variables
            segNum = segNum + 1;
            prevH = -1;
            
        end
        % accumulate center points
        cy = (sy + ey) * 0.5;
        curH = ey - sy + 1;

        cpSection(segNum,:) = [cpSection(segNum,1)+x cpSection(segNum,2)+cy];
        numSec = numSec + 1;
        if mod(segNum,2) ~= 0
            continue; % No polygon area
        end
        if prevH < curH
            
            pp(int32((segNum)/2),:) = [x cy];
            segHeight(int32((segNum)/2)) = curH;
            prevH = curH;
        end

       
    end
     % processing last segment
        if numSec ~=0
            cpSection(end,:) = [cpSection(end,1)/numSec cpSection(end,2)/numSec];
        end

        % pass if num of pivots is not sufficient or segment width i
        % smaller than character height
        if any(any(isnan(pp))) || (segW < max(segHeight)*0.25)
            polys = [polys;NaN([1 28])];
            continue;
        end

        %calc median maximum of pivot points
        halfCharH = median(segHeight)*(expandRatio/2);

        %calculate gradient and apply to make horizontal pivots
        newPivotPoint = [];
        for k = 1:size(pp,1)
            x = pp(k,1);
            cy = pp(k,2);
            dx = cpSection(k*2+1,1) - cpSection(k*2-1,1);
            dy = cpSection(k*2+1,2) - cpSection(k*2-1,2);
            if dx == 0
                newPivotPoint = [newPivotPoint; [x cy-halfCharH x cy+halfCharH]];
                continue;
            end
            rad = -atan2(dy,dx);
            c = halfCharH*cos(rad);
            s = halfCharH*sin(rad);
            newPivotPoint = [newPivotPoint; [x-s cy-c x+s cy+c]];
        end
        % get edge points to cover character heatmaps
        isSppFound = false;
        isEppFound = false;
        gradS = (pp(2,2)-pp(1,2))/(pp(2,1)-pp(1,1)) + (pp(3,2)-pp(2,2))/(pp(3,1)-pp(2,1));
        gradE = (pp(end-1,2)-pp(end,2))/(pp(end-1,1)-pp(end,1)) + (pp(end-2,2)-pp(end-1,2))/(pp(end-2,1)-pp(end-1,1));
        for r = 0.5:rStep:rMax
            dx = 2 * halfCharH * r;
            if ~isSppFound
                lineImg = uint8(zeros(size(wordLabel)));
                dy = gradS * dx;
                p = newPivotPoint(1,:) - [dx dy dx dy];
                lineImg = insertShape(lineImg,'Line',[p(1) p(2) p(3) p(4)]);
                if (sum(wordLabel & lineImg,'all') == 0) || r+2 * rStep >= rMax
                    spp = p;
                    isSppFound = true;
                end
            end
            if ~isEppFound
                lineImg = uint8(zeros(size(wordLabel)));
                dy = gradE * dx;
                p = newPivotPoint(end,:) + [dx dy dx dy];
                lineImg = insertShape(lineImg,'Line',[p(1) p(2) p(3) p(4)]);
                if (sum(wordLabel & lineImg,'all') == 0) || r+2 * rStep >= rMax
                    epp = p;
                    isEppFound = true;
                end
            end
            if isSppFound && isEppFound
                break;
            end
        end
        % pass if boundary of polygon is not found
        if ~(isSppFound&&isEppFound)
            polys = [polys;NaN([1 28])];
            continue;
        end

        % make final polygon
        poly = [];
        poly = [poly warpCoord(Minv,[spp(1),spp(2)])];
        for l = 1:size(newPivotPoint,1)
            p = newPivotPoint(l,:);
            poly = [poly warpCoord(Minv,[p(1),p(2)])];
        end
        poly = [poly warpCoord(Minv,[epp(1),epp(2)])];
        poly = [poly warpCoord(Minv,[epp(3),epp(4)])];
        for l = length(newPivotPoint):-1:1
            p = newPivotPoint(l,:);
            poly = [poly warpCoord(Minv,[p(3) p(4)])];
        end
        poly = [poly warpCoord(Minv,[spp(3) spp(4)])];

        % add to final result
        polys = [polys;poly];
end
end

function res = warpCoord(Minv,pt)
    out = Minv * [pt(1) pt(2) 1]';
    res = [out(1)/out(3) out(2)/out(3)];
end

