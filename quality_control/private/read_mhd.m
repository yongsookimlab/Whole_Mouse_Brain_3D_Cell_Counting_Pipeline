function [img, info]=read_mhd(filename)
% This function is based upon "read_mhd" function from the package
% ReadData3D_version1 from the matlab exchange.
% Copyright (c) 2010, Dirk-Jan Kroon
% [image info ] = read_mhd(filename)
info = mhareadheader(filename);
[path, name, extension] = fileparts(filename);
if (isfield(info,'ElementNumberOfChannels'))
    ndims = str2num(info.ElementNumberOfChannels);
else
    ndims = 1;
end
img = ImageType();
if (ndims == 1)
    data = read_raw([ path  filesep  info.DataFile ], info.Dimensions,info.DataType,'native',0,ndims, info);
    if (data==-1)
        data = read_raw([   info.DataFile ], info.Dimensions,info.DataType,'native',0,ndims);
    end
    img=ImageType(size(data),info.Offset',info.PixelDimensions',reshape(info.TransformMatrix,numel(info.PixelDimensions),numel(info.PixelDimensions)));
    img.data = data;
elseif (ndims == 2)
    clear img;
    
    [datax datay] = read_raw([ path  filesep  info.DataFile], info.Dimensions,info.DataType,'native',0,ndims, info);
    img = VectorImageType(size(datax),info.Offset',info.PixelDimensions',reshape(info.TransformMatrix,numel(info.PixelDimensions),numel(info.PixelDimensions)));
    
    img.datax = datax; clear datax;
    img.datay=datay; clear datay;
    img.data = img.datax.^2+img.datay.^2;
elseif (ndims == 3)
    clear img;
    
    [datax datay dataz] = read_raw([ path  filesep  info.DataFile], info.Dimensions,info.DataType,'native',0,ndims, info);
    img = VectorImageType(size(datax),info.Offset',info.PixelDimensions',reshape(info.TransformMatrix,numel(info.PixelDimensions),numel(info.PixelDimensions)));
    
    img.datax = datax; clear datax;
    img.datay=datay; clear datay;
    img.dataz = dataz; clear dataz;
    img.data = img.datax.^2+img.datay.^2+img.dataz.^2;
end
end
function [rawData, rdy, rdz] =read_raw(filename,imSize,type,endian,skip,ndims, info)
% Reads a raw file
% Inputs: filename, image size, image type, byte ordering, skip
% If you are using an offset to access another slice of the volume image
% be sure to multiply your skip value by the number of bytes of the
% type (ie. float is 4 bytes).
% Inputs: filename, image size, pixel type, endian, number of values to
% skip.
% Output: image
rdy=[];
rdz=[];
fid = fopen(filename,'rb',endian);
%type='uint8';
if (fid < 0)
    display(['Filename ' filename ' does not exist']);
    rawData = -1;
else
    if (ndims == 1)
        status = fseek(fid,skip,'bof');
        if status == 0
            rawData = fread(fid,prod(imSize),type);
            if strcmp(filename(end-3:end),'zraw') || strcmp(lower(info.CompressedData),'true')
                rawData =zlibdecode(uint8(rawData));
            end
            fclose(fid);
            if prod(imSize)~=numel(rawData)
                disp('ERROR: Wrong data size')
                rawData = zeros(imSize);
            else
                rawData = reshape(rawData,imSize);
            end
        else
            rawData = status;
        end
    else
        %disp('Vector Image');
        status = fseek(fid,skip,'bof');
        if status == 0
            r = fread(fid,prod(imSize)*3,type);
            fclose(fid);
            if length(imSize) == 2
                im_size=[ 2 imSize([1 2]) ];
            elseif length(imSize) == 3
                im_size=[ 3 imSize([1 2 3]) ];
            elseif length(imSize) == 4
                im_size=[3 imSize([1 2 3 4]) ];
            end
            r = reshape(r,im_size);
            
            
        else
            r = status;
        end
        if length(imSize) == 2
            rawData=squeeze(r(1,:,:,:));
            rdy=squeeze(r(2,:,:,:));
            rdz=rdy*0;
        elseif length(imSize) == 3
            rawData=squeeze(r(1,:,:,:));
            rdy=squeeze(r(2,:,:,:));
            rdz=squeeze(r(3,:,:,:));
        elseif length(imSize) == 4
            rawData=squeeze(r(1,:,:,:,:));
            rdy=squeeze(r(2,:,:,:,:));
            rdz=squeeze(r(3,:,:,:,:));
        end
        
        
    end
end
end
function info =mhareadheader(filename)
% Function for reading the header of a Insight Meta-Image (.mha,.mhd) file
%
% info  = mha_read_header(filename);
%
% examples:
% 1,  info=mha_read_header()
% 2,  info=mha_read_header('volume.mha');
info = [];
if(exist('filename','var')==0)
    [filename, pathname] = uigetfile('*.mha', 'Read mha-file');
    filename = [pathname filename];
end
fid=fopen(filename,'rb');
if(fid<0)
    fprintf('could not open file %s\n',filename);
    return
end
info.Filename=filename;
info.Format='MHA';
info.CompressedData='false';
info.TransformMatrix = [];
info.CenterOfRotation=[];
readelementdatafile=false;
while(~readelementdatafile)
    str=fgetl(fid);
    if str==-1
        readelementdatafile =true;
        continue;
    end
    
    s=find(str=='=',1,'first');
    if(~isempty(s))
        type=str(1:s-1);
        data=str(s+1:end);
        while(type(end)==' '); type=type(1:end-1); end
        while(data(1)==' '); data=data(2:end); end
    else
        if strcmp(str(1),'#')
            if strcmp(str(2:5),'VENC')
                type='venc';
                data = str2num(str(6:end));
            elseif strcmp(str(2:5),'TXFR')
                type='txfr';
                data = str2num(str(6:end));
            elseif strcmp(str(2:6),'FORCE')
                type='force';
                data = str(7:end);
            elseif strcmp(str(2:6),'ACQFR')
                type='acqfr';
                data = str2num(str(7:end));
            elseif strcmp(str(2:9),'POSITION')
                type='position';
                data = str(10:end);
            elseif strcmp(str(2:10),'HEARTRATE')
                type='heartrate';
                data = str2num(str(11:end));
            elseif strcmp(str(2:11),'PERCEIVEDF')
                type='perceivedf';
                data = str(12:end);
            elseif strcmp(str(2:14),'TRACKERMATRIX')
                type='trackermatrix';
                data = str(15:end);
            elseif strcmp(str(2:12),'TOTALMATRIX')
                type='totalmatrix';
                data = str(13:end);
            elseif numel(str) >= 26 && strcmp(str(2:26),'TIMESTAMP_DNLLAYERTIMELAG')
                type='timestamp_dnllayertimelag';
                data = str2num(str(27:end));
            elseif strcmp(str(2:14),'TIMESTAMP_DNL')
                type='timestamp_dnl';
                data = str2num(str(15:end));
            elseif strcmp(str(2:15),'REORIENTMATRIX')
                type='reorientmatrix';
                data = str(16:end);
            elseif strcmp(str(2:16),'TIMESTAMP_LOCAL')
                type='timestamp_local';
                data = str2num(str(17:end));
            elseif strcmp(str(2:17),'TRANSDUCERMATRIX')
                type='transducermatrix';
                data = str(18:end);
            elseif strcmp(str(2:18),'TIMESTAMP_TRACKER')
                type='timestamp_tracker';
                data = str2num(str(19:end));
            else
                type=''; data=str;
            end
        end
    end
    
    switch(lower(type))
        case 'ndims'
            info.NumberOfDimensions=sscanf(data, '%d')';
        case 'dimsize'
            info.Dimensions=sscanf(data, '%d')';
        case 'elementspacing'
            info.PixelDimensions=sscanf(data, '%lf')';
        case 'elementsize'
            info.ElementSize=sscanf(data, '%lf')';
            if(~isfield(info,'PixelDimensions'))
                info.PixelDimensions=info.ElementSize;
            end
        case 'elementbyteordermsb'
            info.ByteOrder=lower(data);
        case 'anatomicalorientation'
            info.AnatomicalOrientation=data;
        case 'centerofrotation'
            info.CenterOfRotation=sscanf(data, '%lf')';
        case 'offset'
            info.Offset=sscanf(data, '%lf')';
        case 'binarydata'
            info.BinaryData=lower(data);
        case 'compresseddatasize'
            info.CompressedDataSize=sscanf(data, '%d')';
        case 'objecttype',
            info.ObjectType=lower(data);
        case 'transformmatrix'
            info.TransformMatrix=sscanf(data, '%lf')';
        case 'compresseddata';
            info.CompressedData=lower(data);
        case 'binarydatabyteordermsb'
            info.ByteOrder=lower(data);
        case 'elementdatafile'
            info.DataFile=data;
            %readelementdatafile=true;
        case 'elementtype'
            info.DataType=lower(data(5:end));
        case 'headersize'
            val=sscanf(data, '%d')';
            if(val(1)>0), info.HeaderSize=val(1); end
            % Custom fields
        case 'force'
            info.Force=sscanf(data, '%lf')';
        case 'position'
            info.Position=sscanf(data, '%lf')';
        case 'reorientmatrix'
            info.ReorientMatrix=sscanf(data, '%lf')';
            info.ReorientMatrix = reshape(info.ReorientMatrix,4,4);
        case 'transducermatrix'
            info.Transducermatrix=sscanf(data, '%lf')';
            info.Transducermatrix = reshape(info.Transducermatrix,4,4);
        case 'trackermatrix'
            info.TrackerMatrix=sscanf(data, '%lf')';
            info.TrackerMatrix = reshape(info.TrackerMatrix,4,4);
        case 'totalmatrix'
            info.TotalMatrix=sscanf(data, '%lf')';
            info.TotalMatrix = reshape(info.TotalMatrix,4,4);
        case 'timestamp'
            info.Timestamp=sscanf(data, '%lf')';
        case 'perceivedf'
            info.perceivedf=data;
        case '#timestamp_dnl'
            info.timestamp_dnl=str2num(data);
         case '#timestamp_local'
            info.timestamp_local=str2num(data);
         case '#timestamp_tracker'
            info.timestamp_tracker=str2num(data);
        otherwise
            info.(type)=data;
    end
end
if ~numel(info.TransformMatrix)
    info.TransformMatrix = reshape(eye(info.NumberOfDimensions), 1,info.NumberOfDimensions*info.NumberOfDimensions);
end
if ~numel(info.CenterOfRotation)
    info.CenterOfRotation = zeros(1,info.NumberOfDimensions);
end
switch(info.DataType)
    case 'char', info.BitDepth=8;
    case 'uchar', info.BitDepth=8;
    case 'short', info.BitDepth=16;
    case 'ushort', info.BitDepth=16;
    case 'int', info.BitDepth=32;
    case 'uint', info.BitDepth=32;
    case 'float', info.BitDepth=32;
    case 'double', info.BitDepth=64;
    otherwise, info.BitDepth=0;
end
if(~isfield(info,'HeaderSize'))
    info.HeaderSize=ftell(fid);
end
fclose(fid);
end