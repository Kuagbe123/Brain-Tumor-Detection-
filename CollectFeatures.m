function [Features, labels] = CollectFeature(Path)
    Files = dir(Path)
    labels =[];
    Features = [];
    h = waitbar(0,'Please wait...');
    for j=3:length(Files)
        ParrentPath=sprintf('%s\\%s\\*.jpg',Path,Files(j).name);
        PFiles=dir(ParrentPath);
    for i=1:length(PFiles)
        fn = [ParrentPath(1:end-5) PFiles(i).name];
        BrainImg = {PFiles(i).name};
        cat = {Files(j).name};
        x=[Files(j).name];
        title(['Filename:',x,', Image- ',num2str(i)]);
        %%%%%%%%%%%%%%%%preprocess%%%%%%%%%%%
        trainimg1 = imread(fn);  
        trainimg1 = imresize(trainimg1,[256,256]);
        [r c d] = size(trainimg1);
        if d == 3
        trainimg1 = rgb2gray(trainimg1);
        end
        trainimg1 = imresize(trainimg1,[256 256]);
        %trainimg = Preprocess(trainimg1);
        brainImg1 = medfilt2(trainimg1);
        trainimg = imadjust(brainImg1,[.4 .8],[0 1]);
        %%%%%%%%%%%%%%%%%%%%%Brain Tumor Segmentation%%%%%%%%%%%%%%%%%%%
        BW = im2bw(trainimg, 0.6);
        label = bwlabel(BW);

        stats = regionprops(label, 'Solidity', 'Area');

        denisty = [stats.Solidity];
        area = [stats.Area];

        high_dence_area = denisty > 0.5;
        max_area = max(area(high_dence_area));
        tumor_label = find(area == max_area);
        tumor = ismember(label, tumor_label);
        [B,L] = bwboundaries(tumor, 'noholes');
        
        se = strel('line',11,90);
        BW2 = imdilate(tumor,se);
        BW3 = imfill(BW2,'holes');

        se = strel('line',11,90);
        erodedI = imerode(BW3,se);
        erodedI=uint8(erodedI);
        
        imagNew=trainimg1.*erodedI ;
      

       
        %%%%%%%%%%%%%%%%%%%%%%%%Feature Extraction%%%%%%%%%%%%%%%%%%%

         GLCM_mat = graycomatrix(imagNew,'Offset',[2 0;0 2]);

         GLCMstruct = Computefea(GLCM_mat,0);

         v1=GLCMstruct.contr(1);

         v2=GLCMstruct.corrm(1);

         v3=GLCMstruct.cprom(1);

         v4=GLCMstruct.cshad(1);

         v5=GLCMstruct.dissi(1);

         v6=GLCMstruct.energ(1);

         v7=GLCMstruct.entro(1);

         v8=GLCMstruct.homom1(1);

         v9=GLCMstruct.homop(1);

         v10=GLCMstruct.maxpr(1);

         v11=GLCMstruct.sosvh(1);

         v12=GLCMstruct.autoc(1);
         
         TrainImgsFea = [v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12];

         Features = [Features; TrainImgsFea];
         labels=[labels;{Files(j).name}];
         waitbar(i / length(PFiles))
    end
    end
    close(h)
    Truetype{1,1} = 'Benign';
    Truetype{2,1} = 'Malignant';
    save Truetype Truetype
    %H=[H;{Files(3:end).name}]

end