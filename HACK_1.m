% Detecting light-coloured car's in a traffic video

% Accesing the video and getting basic info of it
trafficVid = VideoReader('traffic.mj2');

% Playing the video
implay('traffic.mj2');

%% 1st stage processig

% Selecting a frame of video and applying algorithm on it
% Then the algorith can be applied to all frame's of video

% Regional maxima
darkCarValue = 50;

% Converting RGB video to grey-scale video
% read - returns data, from the file represented by the 
% file-reader object. The number of bytes specified in numbers determines 
% the amount of data that is read.
darkCar = rgb2gray(read(trafficVid,71));

% imextendedmax - returns a binary image that identifies regions with 
% intensity above a specific value, called regional maxima
noDarkCar = imextendedmax(darkCar, darkCarValue);

%Displaying above results
%figure
%imshow(darkCar);
%imshow(noDarkCar);

%% 2nd stage processing

% In this stage, we will be using morphological processing to remove
% objects like lane dividers, lane markings

% Approximation of the shape and size of markings, dividers
sedisk = strel('disk',2);

% imopen - remove small objects while preserving large objects
noSmallStructures = imopen(noDarkCar, sedisk);

% Displaying above results
%imshow(noSmallStructures)

%% 3rd stage processing

% In this stage, we will be applying above algorithm to every frame of the
% video via looping

% Calculating number of frames in video
nframes = trafficVid.NumberOfFrames;

% Refer to line 18, 19, 20
I = read(trafficVid, 1);

% Creating an array of multiple RGB images, in which the centroid of each
% detected car is replaced with a single red pixel
taggedCars = zeros([size(I,1) size(I,2) 3 nframes], class(I));

% Applying algorithm at every frame of video
for k = 1 : nframes
    
    % Please refer above for knowing about functions used
    singleFrame = read(trafficVid, k);
    I = rgb2gray(singleFrame);
    noDarkCars = imextendedmax(I, darkCarValue);
    noSmallStructures = imopen(noDarkCars, sedisk);
    noSmallStructures = bwareaopen(noSmallStructures, 150);

    % Get the area and centroid of each remaining object in the frame. The
    % object with the largest area is the light-colored car.  Create a copy
    % of the original frame and tag the car by changing the centroid pixel
    % value to red.
    taggedCars(:,:,:,k) = singleFrame;

    % No blobs are detected then regionprops() would return an empty struct 
    % ,and [stats.Area] would be empty. In such a case you do not wish to 
    % mark any blob as being associated with a car.
    stats = regionprops(noSmallStructures, {'Centroid','Area'});
    
    if ~isempty([stats.Area])
        
        areaArray = [stats.Area];
        
        % Please refer to https://in.mathworks.com/matlabcentral/answers/
        % 480495-can-someone-expalin-the-if-statement-and-the-code-below-
        % it-and-what-does-taggedcars-doing#comment_746242
        % for explaination
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        c = floor(fliplr(c));
        width = 2;
        row = c(1)-width:c(1)+width;
        col = c(2)-width:c(2)+width;
        taggedCars(row,col,1,k) = 255;
        taggedCars(row,col,2,k) = 0;
        taggedCars(row,col,3,k) = 0;
        
    end
    
end

%% Displaying final results after applying above algorithm's
frameRate = trafficVid.FrameRate;
implay(taggedCars,frameRate);